// actions/getOffenceFull.js
// Generated to match the expected full Offence response payload

const { v4: uuidv4 } = require("uuid");
const xml2js = require("xml2js");
const path = require("path");

const {
  cleanXml,
  readJsonSafe,
  asArray
} = require("../utils/xmlUtils");

const { soapEnvelope } = require("../utils/soapEnvelope");
const { buildWsaHeader } = require("../utils/wsHeaders");

function createHandleGetOffenceFull() {
  return async function handleGetOffenceFull(xmlBody) {

    // ------------------------------------------------------
    // 1. CLEAN + PARSE XML
    // ------------------------------------------------------
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
    const body   = envelope.Body || {};

    const inboundMessageId =
      header.MessageID ||
      header["addr:MessageID"] ||
      uuidv4();

    const reqRoot = body.GetOffenceFullRequest;
    const OFR_ID  = reqRoot.OFR_ID;

    // ------------------------------------------------------
    // 2. LOAD PERSISTED OFFENCE JSON
    // ------------------------------------------------------
    const dataRoot    = path.join(__dirname, "..");
    const offencesDir = path.join(dataRoot, "persisted_keys/offences");
    const offenceFile = path.join(offencesDir, `${OFR_ID}.json`);

    const offence = readJsonSafe(offenceFile, null);

    if (!offence) {
      throw new Error(`No offence data stored for OFR_ID ${OFR_ID}`);
    }

    // ------------------------------------------------------
    // 3. MAP COMPONENTS
    // ------------------------------------------------------
    const headerData   = offence.OffenceHeader || {};
    const rev          = offence.OffenceRevisions || {};
    const wordings     = offence.OffenceWordings || {};
    const actSection   = offence.ActAndSection || {};
    const facts        = offence.StatementOfFacts || {};
    const crown        = offence.CrownOffence || {};
    const cppHeader    = offence.CppOffenceHeader || {};
    const cppRevs      = offence.CppOffenceRevisions || {};
    const appData      = offence.ApplicationDataType || {};
    const civilApp     = offence.CivilApplicationType || {};

    const terminals    = asArray(offence.TerminalEntries);

    // ------------------------------------------------------
    // 4. TERMINAL ENTRY XML
    // ------------------------------------------------------
    const terminalsXml = terminals.map(t => `
      <OffenceTerminalEntriesType>
        <OTE_ID>${t.OTE_ID}</OTE_ID>
        <EntryNumber>${t.EntryNumber}</EntryNumber>
        <Min>${t.Min}</Min>
        <Max>${t.Max}</Max>
        <EntryFormat>${t.EntryFormat}</EntryFormat>
        <EntryPrompt>${t.EntryPrompt}</EntryPrompt>
        <StandardEntryIdentifier>${t.StandardEntryIdentifier || ""}</StandardEntryIdentifier>
        <VersionNumber>1</VersionNumber>
        <ChangedBy>system</ChangedBy>
        <ChangedDate>system</ChangedDate>
        <OFR_ID>${rev.OFR_ID}</OFR_ID>
        <OM_OM_ID>${t.OM_OM_ID || ""}</OM_OM_ID>
        <MenuName>${t.MenuName || ""}</MenuName>
        <CSH_CSH_ID>${t.CSH_CSH_ID || ""}</CSH_CSH_ID>
        <STATUS>DRAFT</STATUS>
      </OffenceTerminalEntriesType>
    `).join("");

    // ------------------------------------------------------
    // 5. RESPONSE BODY XML
    // ------------------------------------------------------
    const bodyXml = `
      <ns58:GetOffenceFullResponse xmlns:ns58="http://www.justice.gov.uk/magistrates/pss/GetOffenceFullResponse">
        <GetOffenceFullResponseType>

          <OffenceHeaderType>
            <OH_ID>${headerData.OH_ID}</OH_ID>
            <CJSCode>${offence.CJSCode}</CJSCode>
            <VersionNumber>1</VersionNumber>
            <ChangedBy>system</ChangedBy>
            <ChangedDate>system</ChangedDate>
            <GoBCode>0</GoBCode>
            <Blocked>${headerData.Blocked || "N"}</Blocked>
            <CSH_CSH_ID>${headerData.CSH_CSH_ID || ""}</CSH_CSH_ID>
          </OffenceHeaderType>

          <OffenceRevisionsType>
            <EditType>${rev.EditType}</EditType>
            <OFR_ID>${rev.OFR_ID}</OFR_ID>
            <Recordable>${rev.Recordable}</Recordable>
            <Reportable>${rev.Reportable}</Reportable>
            <CJSTitle>${rev.CJSTitle}</CJSTitle>
            <CustodialIndicator>${rev.CustodialIndicator}</CustodialIndicator>
            <SOWReference>${rev.SOWReference}</SOWReference>
            <MISClass>${rev.MISClass}</MISClass>
            <OffenceType>${rev.OffenceType}</OffenceType>
            <DVLACode>${rev.DVLACode}</DVLACode>
            <UseFrom>${rev.UseFrom}</UseFrom>
            <UseTo>${rev.UseTo}</UseTo>
            <Notes>${rev.Notes}</Notes>
            <StandardList>${rev.StandardList}</StandardList>
            <MaxPenalty>${rev.MaxPenalty}</MaxPenalty>
            <CSH_CSH_ID>${rev.CSH_CSH_ID}</CSH_CSH_ID>
            <Description>${rev.Description}</Description>
            <HOClass>${rev.HOClass}</HOClass>
            <HOSubClass>${rev.HOSubClass}</HOSubClass>
            <ProceedingsCode>${rev.ProceedingsCode}</ProceedingsCode>
            <CJSTitleCY>${rev.CJSTitleCY}</CJSTitleCY>
          </OffenceRevisionsType>

          <OffenceWordingsType>
            <OW_ID>${wordings.OW_ID}</OW_ID>
            <OffenceWording>${wordings.OffenceWording}</OffenceWording>
            <SLOffenceWording>${wordings.SLOffenceWording}</SLOffenceWording>
            <CSH_CSH_ID>${wordings.CSH_CSH_ID}</CSH_CSH_ID>
          </OffenceWordingsType>

          <ActAndSectionType>
            <OAS_ID>${actSection.OAS_ID}</OAS_ID>
            <ActAndSection>${actSection.ActAndSection}</ActAndSection>
            <SLActAndSection>${actSection.SLActAndSection}</SLActAndSection>
            <CSH_CSH_ID>${actSection.CSH_CSH_ID}</CSH_CSH_ID>
          </ActAndSectionType>

          <StatementOfFactsType>
            <OSF_ID>${facts.OSF_ID}</OSF_ID>
            <StatementOfFacts>${facts.StatementOfFacts}</StatementOfFacts>
            <SLStatementOfFacts>${facts.SLStatementOfFacts}</SLStatementOfFacts>
            <CSH_CSH_ID>${facts.CSH_CSH_ID}</CSH_CSH_ID>
          </StatementOfFactsType>

          ${terminalsXml}

          <CrownOffenceType>
            <RefOffenceId>${crown.RefOffenceId}</RefOffenceId>
            <OffenceClass>${crown.OffenceClass}</OffenceClass>
            <ObsInd>${crown.ObsInd}</ObsInd>
            <CSH_CSH_ID>${crown.CSH_CSH_ID}</CSH_CSH_ID>
          </CrownOffenceType>

          <CppOffenceHeaderType>
            <POH_ID>${cppHeader.POH_ID}</POH_ID>
            <OH_OH_ID>${headerData.OH_ID}</OH_OH_ID>
            <PNLDOffenceStartDate>${cppHeader.PNLDOffenceStartDate}</PNLDOffenceStartDate>
            <PNLDOffenceEndDate>${cppHeader.PNLDOffenceEndDate}</PNLDOffenceEndDate>
            <CSH_CSH_ID>${cppHeader.CSH_CSH_ID}</CSH_CSH_ID>
          </CppOffenceHeaderType>

          <CppOffenceRevisionsType>
            <POR_ID>${cppRevs.POR_ID}</POR_ID>
            <OFR_OFR_ID>${rev.OFR_ID}</OFR_OFR_ID>
            <DateOfLastUpdate>${cppRevs.DateOfLastUpdate}</DateOfLastUpdate>
            <MaxFineTypeMagCtCode>${cppRevs.MaxFineTypeMagCtCode}</MaxFineTypeMagCtCode>
            <MaxFineTypeMagCtDescription>${cppRevs.MaxFineTypeMagCtDescription}</MaxFineTypeMagCtDescription>
            <PNLDStandardOffenceWording>${cppRevs.PNLDStandardOffenceWording}</PNLDStandardOffenceWording>
            <SLPNLDStandardOffenceWording>${cppRevs.SLPNLDStandardOffenceWording}</SLPNLDStandardOffenceWording>
            <ProsecutionTimeLimit>${cppRevs.ProsecutionTimeLimit}</ProsecutionTimeLimit>
            <ModeOfTrial>${cppRevs.ModeOfTrial}</ModeOfTrial>
            <EndorsableFlag>${cppRevs.EndorsableFlag}</EndorsableFlag>
            <LocationFlag>${cppRevs.LocationFlag}</LocationFlag>
            <PrincipalOffenceCategory>${cppRevs.PrincipalOffenceCategory}</PrincipalOffenceCategory>
            <CSH_CSH_ID>${cppRevs.CSH_CSH_ID}</CSH_CSH_ID>
          </CppOffenceRevisionsType>

          <ApplicationDataType>
            <CAD_ID>${appData.CAD_ID}</CAD_ID>
            <CanBeBulk>${appData.CanBeBulk}</CanBeBulk>
            <InitialFee>${appData.InitialFee}</InitialFee>
            <ContestedFee>${appData.ContestedFee}</ContestedFee>
            <ApplicationSynonym>${appData.ApplicationSynonym}</ApplicationSynonym>
            <Exparte>${appData.Exparte}</Exparte>
            <CSH_CSH_ID>${appData.CSH_CSH_ID}</CSH_CSH_ID>
          </ApplicationDataType>

          <CivilApplicationType>
            <CCA_ID>${civilApp.CCA_ID}</CCA_ID>
            <Jurisdiction>${civilApp.Jurisdiction}</Jurisdiction>
            <AppealFlag>${civilApp.AppealFlag}</AppealFlag>
            <SummonsTemplate>${civilApp.SummonsTemplate}</SummonsTemplate>
            <LinkType>${civilApp.LinkType}</LinkType>
            <HearingCode>${civilApp.HearingCode}</HearingCode>
            <ApplicantAppellant>${civilApp.ApplicantAppellant}</ApplicantAppellant>
            <PleaApplicable>${civilApp.PleaApplicable}</PleaApplicable>
            <OffenceActiveOrder>${civilApp.OffenceActiveOrder}</OffenceActiveOrder>
            <CommrOfOathFlag>${civilApp.CommrOfOathFlag}</CommrOfOathFlag>
            <BreachType>${civilApp.BreachType}</BreachType>
            <CourtOfAppealFlag>${civilApp.CourtOfAppealFlag}</CourtOfAppealFlag>
            <CourtExtractAvlFlag>${civilApp.CourtExtractAvlFlag}</CourtExtractAvlFlag>
            <ListingNotifTemplate>${civilApp.ListingNotifTemplate}</ListingNotifTemplate>
            <BoxworkNotifTemplate>${civilApp.BoxworkNotifTemplate}</BoxworkNotifTemplate>
            <ProsecutorThirdPartyFlag>${civilApp.ProsecutorThirdPartyFlag}</ProsecutorThirdPartyFlag>
            <ResentencingActivationCode>${civilApp.ResentencingActivationCode}</ResentencingActivationCode>
            <Prefix>${civilApp.Prefix}</Prefix>
            <CSH_CSH_ID>${civilApp.CSH_CSH_ID}</CSH_CSH_ID>
          </CivilApplicationType>

        </GetOffenceFullResponseType>
      </ns58:GetOffenceFullResponse>
    `;

    const headerXml = buildWsaHeader({
      action: "getOffenceFull",
      messageId: uuidv4(),
      relatesTo: inboundMessageId
    });

    return soapEnvelope(headerXml, bodyXml);
  };
}

module.exports = { createHandleGetOffenceFull };