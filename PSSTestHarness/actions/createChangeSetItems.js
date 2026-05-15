// actions/createChangeSetItems.js
// Built using updateOffenceFull.js as the standard template

const { v4: uuidv4 } = require("uuid");
const xml2js = require("xml2js");
const path = require("path");

const {
  randomId,
  cleanXml,
  asArray,
  ensureDir,
  writeJson
} = require("../utils/xmlUtils");

const { soapEnvelope } = require("../utils/soapEnvelope");
const { buildWsaHeader } = require("../utils/wsHeaders");

function createHandleCreateChangeSetItems() {
  return async function handleCreateChangeSetItems(xmlBody) {
    // --- CLEAN & PARSE XML ---
    xmlBody = cleanXml(xmlBody);

    const parser = new xml2js.Parser({
      explicitArray: false,
      ignoreAttrs: false,
      tagNameProcessors: [xml2js.processors.stripPrefix]
    });

    let parsed;
    try {
      parsed = await parser.parseStringPromise(xmlBody);
    } catch (err) {
      throw new Error("Invalid XML: " + err.message);
    }

    const envelope = parsed.Envelope;
    const header = envelope.Header || {};
    const body = envelope.Body || {};

    const incomingMessageId =
      header.MessageID ||
      header["addr:MessageID"] ||
      uuidv4();

    const reqRoot = body.CreateChangeSetItemsRequest;

    // --- CORE STRUCTURE ---
    const fixedListType = reqRoot.FixedListType;
    const audit = reqRoot.AuditingInformation || {};
    const changeSetType = fixedListType?.DataSet?.ChangeSetType || {};

    const inboundItems = asArray(changeSetType.ChangeSetItemType);

    // --- STORAGE ---
    const dataRoot = path.join(__dirname, "..");
    const itemsDir = path.join(dataRoot, "persisted_keys/change_set_items");
    ensureDir(itemsDir);

    const changeSetHeaderPK =
      inboundItems[0]?.ChangeSetHeaderPK || randomId();

    const persistedFile = path.join(
      itemsDir,
      `${changeSetHeaderPK}.json`
    );

    // --- GENERATE PKs ---
    const generatedItems = inboundItems.map(item => ({
      ...item,
      ChangeSetItemPK: randomId()
    }));

    // --- PERSIST ---
    writeJson(persistedFile, {
      FixedListType: {
        description: fixedListType.$?.description,
        ChangeSetItems: generatedItems
      },
      AuditingInformation: {
        ChangedBy: audit.ChangedBy,
        ChangedDate: audit.ChangedDate
      }
    });

    // --- SOAP RESPONSE ---
    const headerXml = buildWsaHeader({
      action: "createChangeSetItems",
      messageId: uuidv4(),
      relatesTo: incomingMessageId
    });

    const itemsXml = generatedItems
      .map(
        item => `
        <ChangeSetItemsNode>
          <ChangeSetItemsPK>${item.ChangeSetItemPK}</ChangeSetItemsPK>
        </ChangeSetItemsNode>
      `
      )
      .join("");

    const bodyXml = `
      <ns47:CreateChangeSetItemsResponse
        xmlns:ns47="http://www.justice.gov.uk/magistrates/pss/CreateChangeSetItemsResponse">
        ${itemsXml}
      </ns47:CreateChangeSetItemsResponse>
    `;

    return soapEnvelope(headerXml, bodyXml);
  };
}

module.exports = { createHandleCreateChangeSetItems };