{
  title: "FISERV Communicator Open (FCO) - Premiere",
  
  ################################
  # CONNECTION SETTINGS
  ################################
  connection: {
    fields: [
      {
        name: "base_url",
        label: "Base URL",
        optional: false,
        hint: "Obtained from 'Host URL' or 'Token URL' generated for your API Key. Example 'https://bankinghub-cert.fiservapis.com'"
      },
      {
        name: "host_path",
        label: "Host URL Path",
        optional: false,
        hint: "Obtained from 'Host URL' generated for your API Key. Always start with initial slash. Like in '/banking/efx/v1'"
      },
      {
        name: "token_path",
        label: "Token URL Path",
        optional: false,
        hint: "Obtained from 'Token URL' generated for your API Key. Always start with initial slash. Like in '/fts-apim/oauth2/v2'"
      },
      {
        name: "username",
        label: "Username",
        optional: false,
        hint: "Also called 'API key'"
      },
      {
        name: "password",
        label: "Client Secret / Password / API Secret",
        control_type: "password",
        optional: false,
        hint: "Also called 'API secret'"
      },
      {
        name: "organization_id",
        label: "Organization ID",
        optional: false
      }
    ],

    authorization: {
      type: 'custom_auth',

      acquire: lambda do |connection|
        basic_auth = Base64.strict_encode64("#{connection['username']}:#{connection['password']}")
        
        post("#{connection['base_url']}#{connection['token_path']}").
          headers(
            "Content-Type" => "application/x-www-form-urlencoded",
            "Authorization" => "Basic #{basic_auth}"
          ).
          payload(grant_type: 'client_credentials').
          request_format_www_form_urlencoded
      end,

      apply: lambda do |connection|
        require 'securerandom'
        trn_id = SecureRandom.uuid
        
        efx_header = {
          "OrganizationId" => connection['organization_id'],
          "TrnId" => trn_id
        }
        
        headers("Authorization": "Bearer #{connection['access_token']}")
        headers("EFXHeader": efx_header.to_json)
      end,


      refresh_on: [401, 403]
    },

    base_uri: lambda do |connection|
      connection['base_url']
    end
  },
  
  ################################
  # CONNECTION TEST
  ################################
  test: ->(connection) {
    post("#{connection['host_path']}/hostsystemservice/servicing/hostSystem/secured").
      headers(
        "accept" => "application/json",
        "Content-Type" => "application/json",
        "EFXHeader" => {
          "OrganizationId" => connection["organization_id"]
        }.to_json
      ).
      payload(
        {
          "HostSystemSel" => {
            "SystemName" => ["All"]
          }
        }
      )
  },
  
  ################################
  # OBJECT DEFINITIONS
  ################################
  object_definitions: {
    addTransfer_input: {
      fields: lambda do |_, _, object_definitions|
        object_definitions['EFXHeader'].map { |x| x.merge(name: 'EFXHeader_EFXHeader_header') }.map { |x| x.merge({"location"=>"header"}).merge({ "name" => x[:name].to_s+'_header' })}
        .concat([{"name" => "OvrdAutoAckInd", "original_name" => "OvrdAutoAckInd", "control_type" => "checkbox", "type" => "boolean", "location" => "request_body", "hint" => "Override AutoAcknowledge Indicator. Used when the midleware is in charge of auto-acknowledgement of exceptions."}])
        .concat(object_definitions['XferInfoType'].map { |x| x.merge(name: 'XferInfo', label: '') }.map { |x| x.merge({"location"=>"request_body"}).merge({ "name" => x[:name].to_s+'_request_body' })})
      end
    },
    addTransfer_200_output: {
      fields: lambda do |_, _, object_definitions|
        object_definitions['StatusType'].map { |x| x.merge(name: 'Status')}
        .concat(object_definitions['XferStatusRecType'].map { |x| x.merge(name: 'XferStatusRec')})
      end
    },
    getAccountTransactions_input: {
      fields: lambda do |_, _, object_definitions|
        object_definitions['EFXHeader'].map { |x| x.merge(name: 'EFXHeader_EFXHeader_header') }.map { |x| x.merge({"location"=>"header"}).merge({ "name" => x[:name].to_s+'_header' })}
        .concat(object_definitions['RecCtrlInType'].map { |x| x.merge(name: 'RecCtrlInType_RecCtrlIn_request_body', label: 'RecCtrlIn') }.map { |x| x.merge({"location"=>"request_body"}).merge({ "name" => x[:name].to_s+'_request_body' })})
        .concat(object_definitions['AcctTrnSelType'].map { |x| x.merge(name: 'AcctTrnSelType_RecCtrlIn_request_body', label: 'RecCtrlIn') }.map { |x| x.merge({"location"=>"request_body"}).merge({ "name" => x[:name].to_s+'_request_body' })})
      end
    },
    getAccountTransactions_200_output: {
      fields: lambda do |_, _, object_definitions|
        object_definitions['StatusType'].map { |x| x.merge(name: 'Status')}
        .concat(object_definitions['RecCtrlOutType'].map { |x| x.merge(name: 'RecCtrlOut')})
        .concat(object_definitions['AcctTrnRecType'].map { |x| x.merge(name: 'AcctTrnRec')})
      end
    },  
    UpdateParty_input: {
      fields: lambda do |_, _, object_definitions|
        object_definitions['EFXHeader'].map { |x| x.merge(name: 'EFXHeader_EFXHeader_header') }.map { |x| x.merge({"location"=>"header"}).merge({ "name" => x[:name].to_s+'_header' })}
        .concat([{"name" => "OvrdAutoAckInd", "original_name" => "OvrdAutoAckInd", "control_type" => "checkbox", "type" => "boolean", "location" => "request_body", "hint" => "Override AutoAcknowledge Indicator. Used when the midleware is in charge of auto-acknowledgement of exceptions."}])
        .concat(object_definitions['PartyKeysType'].map { |x| x.merge(name: 'PartyKeysType_PartyKeys_request_body') }.map { |x| x.merge({"location"=>"request_body"}).merge({ "name" => x[:name].to_s+'_request_body' })})
        .concat(object_definitions['PersonPartyInfoType'].map { |x| x.merge(name: 'PersonPartyInfoType_PersonPartyInfo_request_body') }.map { |x| x.merge({"location"=>"request_body"}).merge({ "name" => x[:name].to_s+'_request_body' })})
      end
    },
    addParty_input: {
      fields: lambda do |_, _, object_definitions|
        object_definitions['EFXHeader'].map { |x| x.merge(name: 'EFXHeader_EFXHeader_header') }.map { |x| x.merge({"location"=>"header"}).merge({ "name" => x[:name].to_s+'_header' })}
        .concat([{"name" => "OvrdAutoAckInd", "original_name" => "OvrdAutoAckInd", "control_type" => "checkbox", "type" => "boolean", "location" => "request_body", "convert_input" => "boolean_conversion"}])
        .concat(object_definitions['PersonPartyInfoType'].map { |x| x.merge(name: 'PersonPartyInfoType_PersonPartyInfo_request_body') }.map { |x| x.merge({"location"=>"request_body"}).merge({ "name" => x[:name].to_s+'_request_body' })})
      end
    },
    UpdateParty_200_output: {
      fields: lambda do |_, _, object_definitions|
        object_definitions['PartyModRsType'].map { |x| x.merge(name: 'PartyModRsType') }
      end
    },
    addParty_200_output: {
      fields: lambda do |_, _, object_definitions|
        object_definitions['PartyAddRsType'].map { |x| x.merge(name: 'PartyAddRsType') }
      end
    },
    getPartyInqSecure_input: {
      fields: lambda do |_, _, object_definitions|
        object_definitions['EFXHeader'].map { |x| x.merge(name: 'EFXHeader_EFXHeader_header') }.map { |x| x.merge({"location"=>"header"}).merge({ "name" => x[:name].to_s+'_header' })}.concat(object_definitions['PartySelType'].map { |x| x.merge(name: 'PartySelType_PartySel_request_body') }.map { |x| x.merge({"location"=>"request_body"}).merge({ "name" => x[:name].to_s+'_request_body' })})
      end
    },
    getPartyInqSecure_200_output: {
      fields: lambda do |_, _, object_definitions|
        object_definitions['PartyInqRsType'].map { |x| x.merge(name: 'PartyInqRsType') }
      end
    },
    getPartyListInqSecured_input: {
      fields: lambda do |_, _, object_definitions|
        object_definitions['EFXHeader'].map { |x| x.merge(name: 'EFXHeader_EFXHeader_header') }.map { |x| x.merge({"location"=>"header"}).merge({ "name" => x[:name].to_s+'_header' })}.concat(object_definitions['RecCtrlInType'].map { |x| x.merge(name: 'RecCtrlInType_RecCtrlIn_request_body') }.map { |x| x.merge({"location"=>"request_body"}).merge({ "name" => x[:name].to_s+'_request_body' })}).concat(object_definitions['PartyListSelType'].map { |x| x.merge(name: 'PartyListSelType_PartyListSel_request_body') }.map { |x| x.merge({"location"=>"request_body"}).merge({ "name" => x[:name].to_s+'_request_body' })})
      end
    },
    getPartyListInqSecured_200_output: {
      fields: lambda do |_, _, object_definitions|
        object_definitions['PartyListInqRsType'].map { |x| x.merge(name: 'PartyListInqRsType') }
      end
    },
    EFXHeader: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            name: "EFXHeader",
            style: "simple",
            explode: false,
            hint: "The message header request aggregate contains common information for all request messages",
            optional: false,
            properties: object_definitions['Context'].map { |x| x.merge(name: 'Context_Context_request_body') }.map { |x| x.merge({"location" => "request_body"}).merge({ "name" =>  x[:name].to_s+'_request_body' })}.concat([{"maxLength" => 36, "description" => "Organization identifier is a unique identifier that represents the financial institution or holding company.  This identifier does not necessarily match the organization identifier or bank identifier in the backend system. To ensure uniqueness across all institutions in all parts of the world, use the Dun & Bradstreet number.", "name" => "OrganizationId_request_body", "optional" => false, "control_type" => "text", "type" => "string", "original_name" => "OrganizationId", "label" => "OrganizationId", "location" => "request_body"}, {"maxLength" => 36, "description" => "Transaction UUID (Universal Unique Identifier) of the current message.", "name" => "TrnId_request_body", "control_type" => "text", "type" => "string", "original_name" => "TrnId", "label" => "TrnId", "location" => "request_body"}, {"maxLength" => 255, "description" => "Unique vendor identification number provided by Fiserv to identify the vendor. ", "name" => "VendorId_request_body", "control_type" => "text", "type" => "string", "original_name" => "VendorId", "label" => "VendorId", "location" => "request_body"}, {"description" => "For internal use only. Indicates Multi-System environment is enabled.", "name" => "MultiSystemInd_request_body", "control_type" => "checkbox", "type" => "boolean", "toggle_hint" => "Select value", "toggle_field" => {"control_type" => "text", "label" => "MultiSystemInd", "toggle_hint" => "Enter manual value", "toggle_to_secondary_hint" => "Enter manual value", "toggle_to_primary_hint" => "Select value", "type" => "string", "name" => "MultiSystemInd_request_body", "original_name" => "MultiSystemInd", "location" => "request_body"}, "original_name" => "MultiSystemInd", "label" => "MultiSystemInd", "location" => "request_body"}, {"maxLength" => 36, "description" => "For organizations processing the Multi-System environment this identifies the Service Provider (account processor).", "name" => "SvcNbr_request_body", "control_type" => "text", "type" => "string", "original_name" => "SvcNbr", "label" => "SvcNbr", "location" => "request_body"}]),
            example: "{ \"TrnId\": \"622182\", \"OrganizationId\": \"PRMOrg10\", \"VendorId\": \"112233\", \"Context\":{ \"Channel\": \"WEB\" } }",
            control_type: "text",
            type: "object",
            original_name: "EFXHeader",
            label: "EFXHeader"
          }
        ]
      end
    },
    OvrdExceptionDataType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [
              {
                name: "OverrideException_request_body",
                hint: "Override Exception.",
                of: "object",
                properties: object_definitions['OvrdElementType'].map { |x| x.merge(name: 'OvrdElementType_OvrdElement_request_body') }.map { |x| x.merge({"location" => "request_body"}).merge({ "name" =>  x[:name].to_s+'_request_body' })}.concat([{"maxLength" => 80, "name" => "SubjectRole_request_body", "hint" => "Subject Role.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string", "original_name" => "SubjectRole", "label" => "SubjectRole", "location" => "request_body"}, {"maxLength" => 36, "name" => "SubjectIdent_request_body", "hint" => "Subject Identifier.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string", "original_name" => "SubjectIdent", "label" => "SubjectIdent", "location" => "request_body"}, {"maxLength" => 40, "name" => "OvrdExceptionCode_request_body", "hint" => "Overrride Exception Code.Identifies an exception code that is to be overridden. This would be the ServerStatusCode from the Status response.Value should not be more than 40 characters. ", "control_type" => "text", "type" => "string", "original_name" => "OvrdExceptionCode", "label" => "OvrdExceptionCode", "location" => "request_body"}]),
                type: "array",
                original_name: "OverrideException",
                label: "OverrideException",
                location: "request_body"
              }
            ],
            name: "OvrdExceptionDataType",
            label: "OvrdExceptionData",
            type: "object",
            original_name: "OvrdExceptionData"
          }
        ]
      end
    },
    AddrKeysType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['PartyKeysType'].map { |x| x.merge(name: 'PartyKeys') }.concat(object_definitions['AddrFormatTypeType'].map { |x| x.merge(name: 'AddrFormatType') }).concat(object_definitions['AddrTypeType'].map { |x| x.merge(name: 'AddrType') }).concat([{"maxLength" => 36, "name" => "AddressIdent", "hint" => "Address Identification. Used as pointer to a reference of an address. Other identification used as part of the Address object key.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "AddrUse", "hint" => "Address Use. Indicates the use of the address for example Business or Home, Statement, Check, Government, etc.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}]),
            name: "AddrKeysType",
            label: "AddrKeysType",
            type: "object"
          }
        ]
      end
    },
    AddrDelRsType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['StatusType'].map { |x| x.merge(name: 'Status') }.concat(object_definitions['AddrStatusRecType'].map { |x| x.merge(name: 'AddrStatusRec') }),
            label: "AddrDelRsType",
            type: "object",
            name: "AddrDelRsType"
          }
        ]
      end
    },
    EmailKeysType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['PartyKeysType'].map { |x| x.merge(name: 'PartyKeys') }.concat([{"maxLength" => 36, "name" => "EmailIdent", "hint" => "Email Identification. Used as pointer to a reference of an Email. Other identification used as part of the Email object key.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "EmailType", "hint" => "Email Type. Indicates the type of email address.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}]),
            name: "EmailKeysType",
            optional: false,
            label: "EmailKeysType",
            type: "object"
          }
        ]
      end
    },
    EmailDelRsType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['StatusType'].map { |x| x.merge(name: 'Status') }.concat(object_definitions['EmailStatusRecType'].map { |x| x.merge(name: 'EmailStatusRec') }),
            label: "EmailDelRsType",
            type: "object",
            name: "EmailDelRsType"
          }
        ]
      end
    },
    PhoneNumKeysType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['PartyKeysType'].map { |x| x.merge(name: 'PartyKeys') }.concat([{"maxLength" => 36, "name" => "PhoneIdent", "hint" => "Phone Identification. Used as pointer to a reference of an Phone. Other identification used as part of the Phone object key.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PhoneType", "hint" => "Phone Type.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}]),
            name: "PhoneNumKeysType",
            label: "PhoneNumKeysType",
            type: "object"
          }
        ]
      end
    },
    PhoneNumDelRsType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['StatusType'].map { |x| x.merge(name: 'Status') }.concat(object_definitions['PhoneNumStatusRecType'].map { |x| x.merge(name: 'PhoneNumStatusRec') }),
            label: "PhoneNumDelRsType",
            type: "object",
            name: "PhoneNumDelRsType"
          }
        ]
      end
    },
    PartyModRsType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['StatusType'].map { |x| x.merge(name: 'Status') }.concat(object_definitions['PartyStatusRecType'].map { |x| x.merge(name: 'PartyStatusRec') }),
            label: "PartyModRsType",
            type: "object",
            name: "PartyModRsType"
          }
        ]
      end
    },
    PartyAddRsType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['StatusType'].map { |x| x.merge(name: 'Status') }.concat(object_definitions['PartyStatusRecType'].map { |x| x.merge(name: 'PartyStatusRec') }),
            label: "PartyAddRsType",
            type: "object",
            name: "PartyAddRsType"
          }
        ]
      end
    },
    PartySelType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['PartyKeysType'].map { |x| x.merge(name: 'PartyKeysType_PartyKeys_request_body') }.map { |x| x.merge({"location" => "request_body"}).merge({ "name" =>  x[:name].to_s+'_request_body' })},
            name: "PartyKeysType_PartyKeys_request_body",
            optional: false,
            label: "PartySel",
            type: "object",
            original_name: "PartySel"
          }
        ]
      end
    },
    RecCtrlInType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [
              {
                name: "MaxRecLimit_request_body",
                hint: "Maximum record limit is the maximum number of records  that the server should add to the result set which is available to satisfy this request.",
                control_type: "integer",
                type: "integer",
                original_name: "MaxRecLimit",
                label: "MaxRecLimit",
                location: "request_body"
              },
              {
                maxLength: 250,
                name: "Cursor_request_body",
                hint: "Used as the pointer to the next record. It is included  in the request to allow the client to fetch more matching records.Value should not be more than 250 characters. ",
                control_type: "text",
                type: "string",
                original_name: "Cursor",
                label: "Cursor",
                location: "request_body"
              }
            ],
            name: "RecCtrlInType",
            label: "RecCtrlIn",
            hint: "Record Control In",
            type: "object",
            original_name: "RecCtrlIn"
          }
        ]
      end
    },
    PartyInqRsType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['StatusType'].map { |x| x.merge(name: 'Status') }
            .concat(object_definitions['PartyRecType'].map { |x| x.merge(name: 'PartyRec') }),
            name: "PartyInqRsType",
            label: "PartyInqRsType",
            type: "object",
            original_name: "PartyInqRs"
          }
        ]
      end
    },
    PartyRecType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['PartyKeysType'].map { |x| x.merge(name: 'PartyKeys') },
            name: "PartyRecType",
            label: "PartyRecType",
            type: "object",
            original_name: "PartyRec"
          }
        ]
      end
    },
    PartyKeysType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['PartyKeysType'].map { |x| x.merge(name: 'PartyKeys') }
            .concat([
              {"maxLength" => 150, "name" => "PartyId", "original_name" => "PartyId", "hint" => "Party Identifier. Used to uniquely identify a Party record.Value should not be more than 150 characters. ", "control_type" => "text", "type" => "string", "location" => "request_body"}
            ]),
            name: "PartyKeysType",
            label: "PartyKeysType",
            type: "object",
            original_name: "PartyKeys"
          }
        ]
      end
    },
    PersonPartyInfoType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            object_definitions['PartyPrefType'].map { |x| x.merge(name: 'PartyPref', label: 'PartyPref', original_name: 'PartyPref') }
            .concat([{"name" => "EstablishedDt", "original_name" => "EstablishedDt", "type" => "date", "location" => "request_body", "optional" => false}])
            .concat([{"name" => "OriginatingBranch", "original_name" => "OriginatingBranch", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "ResponsibleBranch", "original_name" => "ResponsibleBranch", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat(object_definitions['CreditRiskType'].map { |x| x.merge(name: 'CreditRisk', label: 'CreditRisk') })
            .concat(object_definitions['RelationshipMgrType'].map { |x| x.merge(name: 'RelationshipMgr', label: 'RelationshipMgr') })
            .concat([{"name" => "OEDCode", "original_name" => "OEDCode", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Officer, Employee, DIrector Code. Indicates if the party is an employee of the Bank."}])
            .concat(object_definitions['ClientDefinedDataType'].map { |x| x.merge(name: 'ClientDefinedData') })
            .concat([{"name" => "PartyType", "original_name" => "PartyType", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat(object_definitions['TaxDataInfoType'].map { |x| x.merge(name: 'TaxDataInfo') })
            .concat(object_definitions['DisclosureDataType'].map { |x| x.merge(name: 'DisclosureData') })
            .concat([{"name" => "NAICS", "original_name" => "NAICS", "type" => "array", "of" => "object", "control_type" => "text", "location" => "request_body", "hint" => "NAICS. North American Industry Classification System."}])
            .concat([{"name" => "WithholdingOption", "original_name" => "WithholdingOption", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "Retention", "original_name" => "Retention", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
              .concat(object_definitions['SecretDataType'].map { |x| x.merge(name: 'SecretData') })
              .concat([{"name" => "ExemptOFAC", "original_name" => "ExemptOFAC", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
            .concat([{"name" => "PartyOpenMethod", "original_name" => "PartyOpenMethod", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "TelebancPswd", "original_name" => "TelebancPswd", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "RiskRanking", "original_name" => "RiskRanking", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "TaxExempt", "original_name" => "TaxExempt", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat(object_definitions['PersonDataType'].map { |x| x.merge(name: 'PersonData', label: 'PersonData', original_name: 'PersonData') })
            .concat([{"name" => "BirthDt", "original_name" => "BirthDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "Gender", "original_name" => "Gender", "control_type" => "select", "options" => [ ["Male", "Male"], ["Female", "Female"], ["Unknown", "Unknown"], ["Other", "Other"] ], "location" => "request_body"}])
            .concat([{"name" => "ImmigrationStat", "original_name" => "ImmigrationStat", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "Race", "original_name" => "Race", "control_type" => "select", "options" => [ ["NativeAmerican", "NativeAmerican"], ["Asian", "Asian"], ["Black", "Black"], ["Hispanic", "Hispanic"], ["Caucasian", "Caucasian"], ["Other", "Other"], ["Unknown", "Unknown"], ["RaceNotProvided", "RaceNotProvided"], ["RaceNotApplicable", "RaceNotApplicable"] ], "location" => "request_body"}])
            .concat(object_definitions['OrgPartyInfoType'].map { |x| x.merge(name: 'OrgPartyInfo', label: 'OrgPartyInfo', original_name: 'OrgPartyInfo') }),
            name: "PersonPartyInfoType",
            label: "PersonPartyInfoType",
            type: "object",
            original_name: "PersonPartyInfo"
          }
        ]
      end
    },
    PartyPrefType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "Language", "original_name" => "Language", "control_type" => "select", "options" => [ ["UseInstitution", "UseInstitution"], ["English", "English"], ["Spanish", "Spanish"] ], "location" => "request_body"}],
            name: "PartyPrefType",
            label: "PartyPrefType",
            type: "object",
            original_name: "PartyPref"
          }
        ]
      end
    },
    CreditRiskType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [{"name" => "RiskCategory", "original_name" => "RiskCategory", "control_type" => "text", "type" => "string", "location" => "request_body"}]
            .concat([{"name" => "InternalScore", "original_name" => "InternalScore", "control_type" => "text", "type" => "string", "location" => "request_body"}]),
            name: "CreditRiskType",
            label: "CreditRiskType",
            type: "array",
            of: "object",
            original_name: "CreditRisk"
          }
        ]
      end
    },
    RelationshipMgrType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [{"name" => "RelationshipMgrIdent", "original_name" => "RelationshipMgrIdent", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Relationship Manager Identifier. Identifies officer/employee of financial institution."}]
              .concat([{"name" => "RelationshipRoleType", "original_name" => "RelationshipRoleType", "control_type" => "select", "options" => [ ["Officer", "Officer"], ["SecondOfficer", "SecondOfficer"], ["ThirdOfficer", "ThirdOfficer"], ["FourthOfficer", "FourthOfficer"], ["ReferralOfficer", "ReferralOfficer"] ], "location" => "request_body"}]),
            name: "RelationshipMgrType",
            label: "RelationshipMgrType",
            type: "array",
            of: "object",
            original_name: "RelationshipMgr"
          }
        ]
      end
    },
    ClientDefinedDataType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [{"name" => "DataIdent", "original_name" => "DataIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}]
            .concat([{"name" => "DataType", "original_name" => "DataType", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "Value", "original_name" => "Value", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "DataLength", "original_name" => "DataLength", "type" => "integer", "control_type" => "integer", "control_type" => "integer", "convert_input" => "integer_conversion", "location" => "request_body"}])
            .concat([{"name" => "ExpDt", "original_name" => "ExpDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "Desc", "original_name" => "Desc", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "RequiredFlag", "original_name" => "RequiredFlag", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
            .concat([{"name" => "SearchFlag", "original_name" => "SearchFlag", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
            .concat([{"name" => "GroupNum", "original_name" => "GroupNum", "control_type" => "text", "type" => "string", "location" => "request_body"}]),
            name: "ClientDefinedDataType",
            label: "ClientDefinedDataType",
            type: "array",
            of: "object",
            original_name: "ClientDefinedData"
          }
        ]
      end
    },
    TaxDataInfoType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [{"name" => "TaxIdentType", "original_name" => "TaxIdentType", "control_type" => "select", "options" => [ ["SSN", "SSN"], ["EIN", "EIN"], ["Foreign", "Foreign"], ["ITIN", "ITIN"], ["ATIN", "ATIN"], ["None", "None"], ["Other", "Other"] ], "location" => "request_body"}]
            .concat([{"name" => "TaxIdent", "original_name" => "TaxIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "TaxIdentVerified", "original_name" => "TaxIdentVerified", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
            .concat([{"name" => "TaxIdentVerifiedDt", "original_name" => "TaxIdentVerifiedDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "TaxIdentVerifiedAttempts", "original_name" => "TaxIdentVerifiedAttempts", "type" => "integer", "control_type" => "integer", "control_type" => "integer", "convert_input" => "integer_conversion", "location" => "request_body"}])
            .concat([{"name" => "OtherTaxIdent", "original_name" => "OtherTaxIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "BNotice1Dt", "original_name" => "BNotice1Dt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "BNotice2Dt", "original_name" => "BNotice2Dt", "type" => "date", "location" => "request_body"}])
            .concat(object_definitions['ForeignTaxDataType'].map { |x| x.merge(name: 'ForeignTaxData') }),
            name: "TaxDataInfoType",
            label: "TaxDataInfoType",
            type: "object",
            original_name: "TaxDataInfo"
          }
        ]
      end
    },
    ForeignTaxDataType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [{"name" => "ForeignTaxForms", "original_name" => "ForeignTaxForms", "control_type" => "select", "options" => [ ["1042S", "1042S"], ["W8", "W8"], ["1042SandW8", "1042SandW8"], ["None", "None"] ], "location" => "request_body"}]
            .concat([{"name" => "IncomeCode", "original_name" => "IncomeCode", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Income Code. IRS income code"}])
            .concat([{"name" => "TaxRate", "original_name" => "TaxRate", "type" => "number", "control_type" => "number", "convert_input" => "float_conversion", "location" => "request_body"}])
            .concat([{"name" => "ExemptionCode", "original_name" => "ExemptionCode", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Income Code. IRS income code"}])
            .concat([{"name" => "RecipientStateProv", "original_name" => "RecipientStateProv", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat(object_definitions['CountryCodeType'].map { |x| x.merge(name: 'RecipientCountryCodeType', label: 'RecipientCountryCodeType', original_name: 'RecipientCountryCode') })
            .concat(object_definitions['CountryCodeType'].map { |x| x.merge(name: 'RecipientResidenceCountryType', label: 'RecipientResidenceCountryType', original_name: 'RecipientResidenceCountry') })
            .concat([{"name" => "RecipientPostalCode", "original_name" => "RecipientPostalCode", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "ForeignWithholdingType", "original_name" => "ForeignWithholdingType", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Foreign Withholding Type."}])
            .concat([{"name" => "Chapter3Status", "original_name" => "Chapter3Status", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Chapter 3 Status."}])
            .concat([{"name" => "Chapter4FATCAStatus", "original_name" => "Chapter4FATCAStatus", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Chapter 4 FATCA Status."}])
            .concat([{"name" => "RecipientGIIN", "original_name" => "RecipientGIIN", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "RecipientGlobal Intermediary Identification Number. IRS assigns to a Participating Foreign Financial Institution (PFFI) or Registered Deemed Compliant FFI after a financial institution’s FATCA registration is submitted and approved."}])
            .concat([{"name" => "W8FormType", "original_name" => "W8FormType", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "W8 Form Type."}])
            .concat([{"name" => "ForeignCertDt", "original_name" => "ForeignCertDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "ForeignExpDt", "original_name" => "ForeignExpDt", "type" => "date", "location" => "request_body"}]),
            name: "ForeignTaxDataType",
            label: "ForeignTaxDataType",
            type: "object",
            original_name: "ForeignTaxData"
          }
        ]
      end
    },
    DisclosureDataType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [{"name" => "DisclosureDt", "original_name" => "ExpDt", "type" => "date", "location" => "request_body"}]
            .concat([{"name" => "DisclosureAckType", "original_name" => "DisclosureAckType", "control_type" => "text", "type" => "string", "location" => "request_body"}]),
            name: "DisclosureDataType",
            label: "DisclosureDataType",
            type: "array",
            of: "object",
            original_name: "DisclosureData"
          }
        ]
      end
    },
    SecretDataType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [{"name" => "SecretIdent", "original_name" => "SecretIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}]
            .concat([{"name" => "SecretValue", "original_name" => "SecretValue", "control_type" => "text", "type" => "string", "location" => "request_body"}]),
            name: "SecretDataType",
            label: "SecretDataType",
            type: "array",
            of: "object",
            original_name: "SecretData"
          }
        ]
      end
    },
    PersonDataType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['PersonNameType'].map { |x| x.merge(name: 'PersonName') }
              .concat(object_definitions['ContactType'].map { |x| x.merge(name: 'Contact') })
              .concat(object_definitions['IssuedIdentType'].map { |x| x.merge(name: 'IssuedIdent') }),
            name: "PersonDataType",
            label: "PersonDataType",
            type: "object",
            original_name: "PersonDataType"
          }
        ]
      end
    },
    IssuedIdentType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [{"name" => "IssuedIdentType", "original_name" => "IssuedIdentType", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Issued Identification Type. Valid values: DrvrsLicNb, BirthCertificate, HealthCard, Military, AlnRegnNb, IdntyCardNb, VoterRegistration, PsptNb, MplyrIdNb, TaxIdNb,  SclSctyNb, NRAPersonal, NRABusiness, Other."}]
              .concat([{"name" => "IssuedIdentId", "original_name" => "IssuedIdentId", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "IssuedIdentValue", "original_name" => "IssuedIdentValue", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Issued Identification Value. Identification value associated with the identification type."}])
              .concat([{"name" => "Issuer", "original_name" => "Issuer", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "IssueDt", "original_name" => "IssueDt", "type" => "date", "location" => "request_body"}])
              .concat([{"name" => "ExpDt", "original_name" => "ExpDt", "type" => "date", "location" => "request_body"}]),
            name: "IssuedIdentType",
            label: "IssuedIdentType",
            type: "array",
            of: "object",
            original_name: "IssuedIdent"
          }
        ]
      end
    },
    PersonNameType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [
              {"name" => "NameType", "original_name" => "NameType", "control_type" => "select", "options" => [ ["Primary", "Primary"], ["Secondary", "Secondary"], ["Legal", "Legal"] ], "location" => "request_body"},
              {"name" => "FullName", "original_name" => "FullName", "control_type" => "text", "type" => "string", "location" => "request_body"},
              {"name" => "FamilyName", "original_name" => "FamilyName", "control_type" => "text", "type" => "string", "location" => "request_body"},
              {"name" => "GivenName", "original_name" => "GivenName", "control_type" => "text", "type" => "string", "location" => "request_body"},
              {"name" => "MiddleName", "original_name" => "MiddleName", "control_type" => "text", "type" => "string", "location" => "request_body"},
              {"name" => "NameSuffix", "original_name" => "NameSuffix", "control_type" => "select", "options" => [ ["II", "II"], ["III", "III"], ["IV", "IV"], ["Jr.", "Jr."], ["Sr.", "Sr."] ], "location" => "request_body"},
              {"name" => "NameFormat", "original_name" => "NameFormat", "control_type" => "select", "options" => [ ["None", "None"], ["Primary", "Primary"], ["Secondary", "Secondary"] ], "location" => "request_body"},
              {"name" => "LegalName", "original_name" => "LegalName", "control_type" => "text", "type" => "string", "location" => "request_body"}
            ],
            name: "PersonNameType",
            label: "PersonNameType",
            type: "array",
            of: "object",
            original_name: "PersonName"
          }
        ]
      end
    },
    ContactType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['PostAddrType'].map { |x| x.merge(name: 'PostAddr') }
              .concat(object_definitions['PhoneNumType'].map { |x| x.merge(name: 'PhoneNum') })
              .concat(object_definitions['EmailType'].map { |x| x.merge(name: 'Email') })
            .concat(object_definitions['WebAddrType'].map { |x| x.merge(name: 'WebAddr') }),
            name: "ContactType",
            label: "ContactType",
            type: "array",
            of: "object",
            original_name: "Contact"
          }
        ]
      end
    },
    PhoneNumType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties:
            [{"name" => "PhoneType", "original_name" => "PhoneType", "control_type" => "select", "options" => [ ["Home", "Home"], ["Work", "Work"], ["Mobile", "Mobile"], ["Fax", "Fax"], ["Pager", "Pager"], ["Modem", "Modem"], ["Other", "Other"], ["International Home", "International Home"], ["International Work", "International Work"], ["International Mobile", "International Mobile"] ], "location" => "request_body"}]
              .concat([{"name" => "PhoneIdent", "original_name" => "PhoneIdent", "type" => "integer", "control_type" => "integer", "control_type" => "integer", "convert_input" => "integer_conversion", "location" => "request_body", "hint" => "Phone Identifier. Use when you have more than one occurrence of a phone type  (for example 5 Mobile phones). This element serializes the phones."}])
              .concat([{"name" => "Phone", "original_name" => "Phone", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "PhoneExchange", "original_name" => "PhoneExchange", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "PreferredPhone", "original_name" => "PreferredPhone", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
              .concat([{"name" => "Priority", "original_name" => "Priority", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "DoNotContactInd", "original_name" => "DoNotContactInd", "control_type" => "checkbox", "type" => "boolean", "location" => "request_body"}])
              .concat([{"name" => "PhoneDesc", "original_name" => "PhoneDesc", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat(object_definitions['CountryCodeType'].map { |x| x.merge(name: 'CountryCode') })
              .concat([{"name" => "UpDt", "original_name" => "UpDt", "type" => "date", "location" => "request_body"}]),
            name: "PhoneNumType",
            label: "PhoneNumType",
            type: "object",
            original_name: "PhoneNum"
          }
        ]
      end
    },
    EmailType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties:
              [{"name" => "EmailIdent", "original_name" => "EmailIdent", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Email Identification."}]
            .concat([{"name" => "EmailType", "original_name" => "EmailType", "control_type" => "select", "options" => [ ["Business", "Business"], ["Person", "Person"] ], "location" => "request_body"}])
              .concat([{"name" => "EmailTypeEnumDesc", "original_name" => "EmailTypeEnumDesc", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Email Type Enumeration Description."}])
              .concat([{"name" => "EmailAddr", "original_name" => "EmailAddr", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "PreferredEmail", "original_name" => "PreferredEmail", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
              .concat([{"name" => "Priority", "original_name" => "Priority", "control_type" => "checkbox", "type" => "boolean", "location" => "request_body", "hint" => "Priority Code."}]),
            name: "EmailType",
            label: "EmailType",
            type: "object",
            original_name: "Email"
          }
        ]
      end
    },
    WebAddrType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties:
              [{"name" => "WebAddrIdent", "original_name" => "WebAddrIdent", "type" => "integer", "control_type" => "integer", "control_type" => "integer", "convert_input" => "integer_conversion", "location" => "request_body"}]
              .concat([{"name" => "WebAddrLink", "original_name" => "WebAddrLink", "control_type" => "text", "type" => "string", "location" => "request_body"}]),
            name: "WebAddrType",
            label: "WebAddrType",
            type: "object",
            original_name: "WebAddr"
          }
        ]
      end
    },
    PostAddrType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
              [{"name" => "OpenDt", "original_name" => "OpenDt", "type" => "date", "location" => "request_body"}]
              .concat([{"name" => "AddressIdent", "original_name" => "AddressIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "OriginatingBranch", "original_name" => "OriginatingBranch", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "ResponsibleBranch", "original_name" => "ResponsibleBranch", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "AddrUse", "original_name" => "AddrUse", "control_type" => "select", "options" => [ ["Business", "Business"], ["Home", "Home"], ["Personal", "Personal"], ["Tax", "Tax"] ], "location" => "request_body"}])
              .concat([{"name" => "AddrFormatType", "original_name" => "AddrFormatType", "control_type" => "select", "location" => "request_body", "options" => [ ["Label", "Label"] ]}])
              .concat([{"name" => "Addr1", "original_name" => "Addr1", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "Addr2", "original_name" => "Addr2", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "Addr3", "original_name" => "Addr3", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "Addr4", "original_name" => "Addr4", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "Addr5", "original_name" => "Addr5", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "Addr6", "original_name" => "Addr6", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "City", "original_name" => "City", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "County", "original_name" => "County", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "District", "original_name" => "District", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "StateProv", "original_name" => "StateProv", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "State/Province. ISO 3166-2:US codes."}])
              .concat([{"name" => "PostalCode", "original_name" => "PostalCode", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "Country", "original_name" => "Country", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat(object_definitions['CountryCodeType'].map { |x| x.merge(name: 'CountryCode') })
              .concat([{"name" => "AddrType", "original_name" => "AddrType", "control_type" => "select", "options" => [ ["Primary", "Primary"], ["PrimaryPending", "PrimaryPending"], ["Secondary", "Secondary"], ["Seasonal", "Seasonal"], ["Previous", "Previous"], ["Physical", "Physical"] ], "location" => "request_body"}])
              .concat(object_definitions['TimeFrameType'].map { |x| x.merge(name: 'TimeFrame') })
              .concat([{"name" => "Retention", "original_name" => "Retention", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body", "hint" => "Retention. Indicates whether the records are to be retained or deleted based on Service Provider criteria."}])
              .concat([{"name" => "CensusTract", "original_name" => "CensusTract", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Census Track. Contains the census tract number assigned to the address."}])
              .concat([{"name" => "CensusBlock", "original_name" => "CensusBlock", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Census Block. Contains the census block group designation for the block where the address is within a census tract."}])
              .concat([{"name" => "ForeignFlag", "original_name" => "ForeignFlag", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
              .concat([{"name" => "HandlingCode", "original_name" => "HandlingCode", "control_type" => "text", "type" => "string", "convert_input" => "integer_conversion", "location" => "request_body", "hint" => "Handling Code. Indicates special handling of notification and statement forms."}])
              .concat([{"name" => "HandlingCodeOption", "original_name" => "HandlingCodeOption", "control_type" => "select", "options" => [ ["StatementsNoticesChecks", "StatementsNoticesChecks"], ["Statements", "Statements"], ["StatementsNotices", "StatementsNotices"], ["StatementsChecks", "StatementsChecks"], ["Notices", "Notices"], ["NoticesChecks", "NoticesChecks"], ["Checks", "Checks"], ["DoNotPrint", "DoNotPrint"], ["UsePortfolio", "UsePortfolio"], ["UseDefault", "UseDefault"] ], "location" => "request_body"}])
              .concat([{"name" => "MSACode", "original_name" => "MSACode", "type" => "integer", "control_type" => "integer", "control_type" => "integer", "convert_input" => "integer_conversion", "location" => "request_body", "hint" => "MSA Code. MSAs are defined by the U.S. Office of Management and Budget (OMB), and used by the U.S. Census Bureau and other federal government agencies for statistical purposes"}]),
            name: "PostAddrType",
            label: "PostAddrType",
            type: "object",
            original_name: "PostAddr"
          }
        ]
      end
    },
    CountryCodeType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [
              {"name" => "CountryCodeSource", "original_name" => "CountryCodeSource", "control_type" => "select", "options" => [ ["SPCountryCode", "SPCountryCode"] ], "location" => "request_body"},
              {"name" => "CountryCodeValue", "original_name" => "CountryCodeValue", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Country Code Value. Indicates the Country Code Value within the CountryCodeSource table specified."},
              {"name" => "CountryCodeValueEnumDesc", "original_name" => "CountryCodeValueEnumDesc", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Country Code Value Enumeration Description."}
            ],
            name: "CountryCodeType",
            label: "CountryCodeType",
            type: "object",
            original_name: "CountryCode"
          }
        ]
      end
    },
    TimeFrameType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [
              {"name" => "StartDt", "original_name" => "StartDt", "type" => "date", "location" => "request_body"},
              {"name" => "EndDt", "original_name" => "EndDt", "type" => "date", "location" => "request_body"}
            ],
            name: "TimeFrameType",
            label: "TimeFrameType",
            type: "object",
            original_name: "TimeFrame"
          }
        ]
      end
    },
    OrgPartyInfoType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
        object_definitions['PartyPrefType'].map { |x| x.merge(name: 'PartyPref', label: 'PartyPref', original_name: 'PartyPref') }
        .concat([{"name" => "EstablishedDt", "original_name" => "EstablishedDt", "type" => "date", "location" => "request_body", "optional" => false}])
        .concat([{"name" => "OriginatingBranch", "original_name" => "OriginatingBranch", "control_type" => "text", "type" => "string", "location" => "request_body"}])
        .concat([{"name" => "ResponsibleBranch", "original_name" => "ResponsibleBranch", "control_type" => "text", "type" => "string", "location" => "request_body"}])
        .concat(object_definitions['CreditRiskType'].map { |x| x.merge(name: 'CreditRisk', label: 'CreditRisk') })
        .concat(object_definitions['RelationshipMgrType'].map { |x| x.merge(name: 'RelationshipMgr', label: 'RelationshipMgr') })
        .concat([{"name" => "OEDCode", "original_name" => "OEDCode", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Officer, Employee, DIrector Code. Indicates if the party is an employee of the Bank."}])
        .concat(object_definitions['ClientDefinedDataType'].map { |x| x.merge(name: 'ClientDefinedData') })
        .concat([{"name" => "PartyType", "original_name" => "PartyType", "control_type" => "text", "type" => "string", "location" => "request_body"}])
        .concat(object_definitions['TaxDataInfoType'].map { |x| x.merge(name: 'TaxDataInfo') })
        .concat(object_definitions['DisclosureDataType'].map { |x| x.merge(name: 'DisclosureData') })
        .concat([{"name" => "NAICS", "original_name" => "NAICS", "type" => "array", "of" => "object", "control_type" => "text", "location" => "request_body", "hint" => "NAICS. North American Industry Classification System."}])
        .concat([{"name" => "WithholdingOption", "original_name" => "WithholdingOption", "control_type" => "text", "type" => "string", "location" => "request_body"}])
        .concat([{"name" => "Retention", "original_name" => "Retention", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
        .concat(object_definitions['SecretDataType'].map { |x| x.merge(name: 'SecretData') })
        .concat([{"name" => "ExemptOFAC", "original_name" => "ExemptOFAC", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
        .concat([{"name" => "PartyOpenMethod", "original_name" => "PartyOpenMethod", "control_type" => "text", "type" => "string", "location" => "request_body"}])
        .concat([{"name" => "TelebancPswd", "original_name" => "TelebancPswd", "control_type" => "text", "type" => "string", "location" => "request_body"}])
        .concat([{"name" => "RiskRanking", "original_name" => "RiskRanking", "control_type" => "text", "type" => "string", "location" => "request_body"}])
        .concat([{"name" => "TaxExempt", "original_name" => "TaxExempt", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat(object_definitions['OrgDataType'].map { |x| x.merge(name: 'OrgData') }),
            name: "OrgPartyInfoType",
            label: "OrgPartyInfoType",
            type: "object",
            original_name: "OrgName"
          }
        ]
      end
    },
    OrgDataType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
              object_definitions['ContactType'].map { |x| x.merge(name: 'Contact') }
              .concat(object_definitions['IssuedIdentType'].map { |x| x.merge(name: 'IssuedIdent') })
              .concat(object_definitions['OrgNameType'].map { |x| x.merge(name: 'OrgName') }),
            name: "OrgDataType",
            label: "OrgDataType",
            type: "object",
            original_name: "OrgData"
          }
        ]
      end
    },
    OrgNameType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [{"name" => "NameType", "original_name" => "NameType", "control_type" => "select", "options" => [ ["Primary", "Primary"], ["Secondary", "Secondary"] ], "location" => "request_body"}]
              .concat([{"name" => "NameIdent", "original_name" => "NameIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "Name", "original_name" => "Name", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "LegalName", "original_name" => "LegalName", "control_type" => "text", "type" => "string", "location" => "request_body"}])
              .concat([{"name" => "NameFormat", "original_name" => "NameFormat", "control_type" => "select", "options" => [ ["None", "None"], ["NonPersonal", "NonPersonal"] ], "location" => "request_body"}]),
            name: "OrgNameType",
            label: "OrgNameType",
            type: "array",
            of: "object",
            original_name: "OrgName"
          }
        ]
      end
    },
    PartyListSelType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['PartyKeysType'].map { |x| x.merge(name: 'PartyKeysType_PartyKeys_request_body') }.map { |x| x.merge({"location" => "request_body"}).merge({ "name" =>  x[:name].to_s+'_request_body' })}.concat(object_definitions['PersonNameSelType'].map { |x| x.merge(name: 'PersonNameSelType_PersonNameSel_request_body') }.map { |x| x.merge({"location" => "request_body"}).merge({ "name" =>  x[:name].to_s+'_request_body' })}).concat(object_definitions['ClientDefinedSearchType'].map { |x| x.merge(name: 'ClientDefinedSearchType_ClientDefinedSearch_request_body') }.map { |x| x.merge({"location" => "request_body"}).merge({ "name" =>  x[:name].to_s+'_request_body' })}).concat([{"name" => "PersonIndicator_request_body", "hint" => "Person Indicator. Use to indicate the Party is a Person (true).", "control_type" => "checkbox", "type" => "boolean", "toggle_hint" => "Select value", "toggle_field" => {"control_type" => "text", "label" => "PersonIndicator", "toggle_hint" => "Enter manual value", "toggle_to_secondary_hint" => "Enter manual value", "toggle_to_primary_hint" => "Select value", "type" => "string", "name" => "PersonIndicator_request_body", "original_name" => "PersonIndicator", "location" => "request_body"}, "original_name" => "PersonIndicator", "label" => "PersonIndicator", "location" => "request_body"}, {"maxLength" => 32, "name" => "IssuedIdentValue_request_body", "hint" => "Issued Identification Value. Identification value associated with the identification type.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string", "original_name" => "IssuedIdentValue", "label" => "IssuedIdentValue", "location" => "request_body"}, {"name" => "IssuedIdentType_request_body", "hint" => "Issued Identification Type. Valid values: DrvrsLicNb, BirthCertificate, HealthCard, Military, AlnRegnNb, IdntyCardNb, VoterRegistration, PsptNb, MplyrIdNb, TaxIdNb,  SclSctyNb, NRAPersonal, NRABusiness, Other.", "original_name" => "IssuedIdentType", "label" => "IssuedIdentType", "location" => "request_body"}, {"maxLength" => 130, "name" => "Name_request_body", "hint" => "Name.Value should not be more than 130 characters. ", "control_type" => "text", "type" => "string", "original_name" => "Name", "label" => "Name", "location" => "request_body"}, {"name" => "SoundexNameInd_request_body", "hint" => "Soundex Name Indicator. Indicates whether to search for soundex values for the name.", "control_type" => "checkbox", "type" => "boolean", "toggle_hint" => "Select value", "toggle_field" => {"control_type" => "text", "label" => "SoundexNameInd", "toggle_hint" => "Enter manual value", "toggle_to_secondary_hint" => "Enter manual value", "toggle_to_primary_hint" => "Select value", "type" => "string", "name" => "SoundexNameInd_request_body", "original_name" => "SoundexNameInd", "location" => "request_body"}, "original_name" => "SoundexNameInd", "label" => "SoundexNameInd", "location" => "request_body"}, {"maxLength" => 80, "name" => "NameSearchCode_request_body", "hint" => "Name Search Code.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string", "original_name" => "NameSearchCode", "label" => "NameSearchCode", "location" => "request_body"}, {"maxLength" => 80, "name" => "NameTypeOption_request_body", "hint" => "Name Type Option. Use this field to indicate if the search criteria sent in Name should be searched in records other than the customer record, such as account titles or alternate name records.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string", "original_name" => "NameTypeOption", "label" => "NameTypeOption", "location" => "request_body"}, {"maxLength" => 64, "name" => "Addr1_request_body", "hint" => "Address Line 1.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string", "original_name" => "Addr1", "label" => "Addr1", "location" => "request_body"}, {"maxLength" => 12, "name" => "TaxIdent_request_body", "hint" => "Tax Identification.Value should not be more than 12 characters. ", "control_type" => "text", "type" => "string", "original_name" => "TaxIdent", "label" => "TaxIdent", "location" => "request_body"}, {"maxLength" => 4, "name" => "LastFourSSNOrTaxId_request_body", "hint" => "Last Four SSN or Tax Identifier.Value should not be more than 4 characters. ", "control_type" => "text", "type" => "string", "original_name" => "LastFourSSNOrTaxId", "label" => "LastFourSSNOrTaxId", "location" => "request_body"}, {"name" => "Phone_request_body", "hint" => "Phone.", "control_type" => "text", "type" => "string", "original_name" => "Phone", "label" => "Phone", "location" => "request_body"}, {"maxLength" => 254, "name" => "EmailAddr_request_body", "hint" => "Email Address.Value should not be more than 254 characters. ", "control_type" => "text", "type" => "string", "original_name" => "EmailAddr", "label" => "EmailAddr", "location" => "request_body"}, {"maxLength" => 36, "name" => "AcctId_request_body", "hint" => "Account Identifier. Uniquely identifies an account held at a financial institution.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string", "original_name" => "AcctId", "label" => "AcctId", "location" => "request_body"}, {"maxLength" => 80, "name" => "AcctType_request_body", "hint" => "Account Type. Classifies the type of product with which an account is associated. This element is required when adding a new account and by using this value we can identify if the account is a savings, a checking, a time deposit, loan account, etc.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string", "original_name" => "AcctType", "label" => "AcctType", "location" => "request_body"}, {"maxLength" => 36, "name" => "PortId_request_body", "hint" => "Portfolio Identifier.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string", "original_name" => "PortId", "label" => "PortId", "location" => "request_body"}, {"maxLength" => 40, "name" => "City_request_body", "hint" => "City.Value should not be more than 40 characters. ", "control_type" => "text", "type" => "string", "original_name" => "City", "label" => "City", "location" => "request_body"}, {"maxLength" => 80, "name" => "StateProv_request_body", "hint" => "State/Province. ISO 3166-2:US codes.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string", "original_name" => "StateProv", "label" => "StateProv", "location" => "request_body"}, {"maxLength" => 11, "name" => "PostalCode_request_body", "hint" => "Postal Code. ZipCode in the US.Value should not be more than 11 characters. ", "control_type" => "text", "type" => "string", "original_name" => "PostalCode", "label" => "PostalCode", "location" => "request_body"}, {"name" => "BirthDt_request_body", "hint" => "Birth Date.", "control_type" => "date", "type" => "date", "original_name" => "BirthDt", "label" => "BirthDt", "location" => "request_body"}, {"maxLength" => 200, "name" => "Desc_request_body", "hint" => "Description.Value should not be more than 200 characters. ", "control_type" => "text", "type" => "string", "original_name" => "Desc", "label" => "Desc", "location" => "request_body"}, {"name" => "OEDCode_request_body", "hint" => "Officer, Employee, DIrector Code. Indicates if the party is an employee of the Bank.", "original_name" => "OEDCode", "label" => "OEDCode", "location" => "request_body"}, {"maxLength" => 32, "name" => "OriginatingBranch_request_body", "hint" => "Originating Branch. Branch first originated the relationship with party or created the account.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string", "original_name" => "OriginatingBranch", "label" => "OriginatingBranch", "location" => "request_body"}]),
            name: "PartyListSelType",
            optional: false,
            label: "PartyListSel",
            type: "object",
            original_name: "PartyListSel"
          }
        ]
      end
    },
    PartyListInqRsType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['StatusType'].map { |x| x.merge(name: 'Status') }.concat(object_definitions['RecCtrlOutType'].map { |x| x.merge(name: 'RecCtrlOut') }).concat([{"name" => "PartyListRec", "hint" => "Party List Record.", "of" => "object", "properties" => [{"properties" => [{"properties" => [{"maxLength" => 1024, "name" => "SvcProviderName", "hint" => "Service Provider Name is a globally unique identifier for a service provider.Value should not be more than 1024 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 36, "name" => "SvcNbr", "hint" => "Service Number.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 32, "name" => "SvcName", "hint" => "Service Name.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "SvcIdentType", "ref_uuid" => "2321b6a9-1e45-46c3-9c1a-a3d02c196db7", "name" => "SvcIdent", "label" => "SvcIdentType", "type" => "object"}, {"maxLength" => 150, "name" => "PartyId", "hint" => "Party Identifier. Used to uniquely identify a Party record.Value should not be more than 150 characters. ", "control_type" => "text", "type" => "string"}, {"object_ref_name" => "PartyIdentTypeType", "ref_uuid" => "acd93e85-2ef4-42fd-9e65-940210b111ce", "name" => "PartyIdentType", "label" => "PartyIdentTypeType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["TaxIdent", "TaxIdent"], ["IBId", "IBId"], ["Name", "Name"], ["MemberNum", "MemberNum"], ["OrgNum", "OrgNum"], ["PersonNum", "PersonNum"]]}, {"maxLength" => 60, "name" => "PartyIdent", "hint" => "Party Identification.Value should not be more than 60 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "PartyKeysType", "ref_uuid" => "d222c020-5fd6-4be9-9832-084017f42df0", "name" => "PartyKeys", "optional" => false, "label" => "PartyKeysType", "type" => "object"}, {"properties" => [{"properties" => [{"maxLength" => 80, "name" => "MemberGroup", "hint" => "Member Group.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 36, "name" => "MemberNum", "hint" => "Member Number.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "MemberDataType", "ref_uuid" => "9eca2c6b-3b8f-4db3-816c-9d14229f9221", "name" => "MemberData", "label" => "MemberDataType", "hint" => "Member Data.", "type" => "object"}, {"maxLength" => 80, "name" => "PartySelType", "hint" => "Party Selection Type.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PartyType", "hint" => "Party Type.Used to further specify the type of Party.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PartyTypeEnumDesc", "hint" => "Party Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "Contact", "hint" => "Contact. This aggregate contains a person's or organization's contact information", "of" => "object", "properties" => [{"properties" => [{"maxLength" => 80, "name" => "PhoneType", "optional" => false, "hint" => "Phone Type.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PhoneTypeEnumDesc", "hint" => "Phone Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PhoneIdent", "hint" => "Phone Identifier. Use when you have more than one occurrence of a phone type  (for example 5 Mobile phones). This element serializes the phones.", "control_type" => "integer", "type" => "integer"}, {"name" => "Phone", "hint" => "Phone.", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PhoneExchange", "hint" => "Phone Exchange.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PreferredPhone", "hint" => "Preferred Phone.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 10, "name" => "Priority", "hint" => "Priority Code.Value should not be more than 10 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "DoNotContactInd", "hint" => "Do Not Contact Indicator.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 30, "name" => "PhoneDesc", "hint" => "Phone Description.Value should not be more than 30 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"maxLength" => 80, "name" => "CountryCodeSource", "hint" => "Country Code Source. Used with CountryCodeValue to indicate the Country Code Source table.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValue", "optional" => false, "hint" => "Country Code Value. Indicates the Country Code Value within the CountryCodeSource table specified.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValueEnumDesc", "hint" => "Country Code Value Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "CountryCodeType", "ref_uuid" => "ee56204d-5b19-4df8-bb91-5caef4d17f78", "name" => "CountryCode", "label" => "CountryCodeType", "type" => "object"}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "UpDt", "hint" => "Update Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "PhoneNumType", "ref_uuid" => "052f5504-7bc7-49ce-bb50-4963d4db62e5", "name" => "PhoneNum", "label" => "PhoneNumType", "type" => "object"}, {"object_ref_name" => "PostAddrType", "ref_uuid" => "6fefb81c-9e7f-4858-a982-c24314da039c", "label" => "PostAddrType", "properties" => [{"name" => "OpenDt", "hint" => "Open Date.", "control_type" => "date", "type" => "date"}, {"name" => "RelationshipMgr", "hint" => "Relationship Manager. Stores information about the FI officers that have management responsibility of the Party, the Account or the Card.", "of" => "object", "properties" => [{"maxLength" => 36, "name" => "RelationshipMgrIdent", "optional" => false, "hint" => "Relationship Manager Identifier. Identifies officer/employee of financial institution.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "RelationshipMgrIdentEnumDesc", "hint" => "Relationship Manager Identifier Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"object_ref_name" => "RelationshipRoleType", "ref_uuid" => "48cc411f-cfe1-490c-9bad-9c787340da3d", "name" => "RelationshipRole", "label" => "RelationshipRoleType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["Officer", "Officer"], ["SecondOfficer", "SecondOfficer"], ["ThirdOfficer", "ThirdOfficer"], ["FourthOfficer", "FourthOfficer"], ["ReferralOfficer", "ReferralOfficer"]]}, {"maxLength" => 80, "name" => "RelationshipRoleEnumDesc", "hint" => "Relationship Role Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "type" => "array"}, {"maxLength" => 32, "name" => "OriginatingBranch", "hint" => "Originating Branch. Branch first originated the relationship with party or created the account.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "OriginatingBranchEnumDesc", "hint" => "Originating Branch Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 32, "name" => "PreferredBranch", "hint" => "Preferred Branch. The branch preferred by the customer to conduct business.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PreferredBranchEnumDesc", "hint" => "Preferred Branch Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 32, "name" => "ResponsibleBranch", "hint" => "Responsible Branch. Branch responsible for the relationship.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "ResponsibleBranchEnumDesc", "hint" => "Responsible Branch Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "NameIdent", "hint" => "Name Identifier.", "of" => "string", "type" => "array"}, {"maxLength" => 36, "name" => "AddressIdent", "hint" => "Address Identification. Used as pointer to a reference of an address. Other identification used as part of the Address object key.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "AddrUse", "hint" => "Address Use. Indicates the use of the address for example Business or Home, Statement, Check, Government, etc.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "AddrUseEnumDesc", "hint" => "Address Use  Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"object_ref_name" => "AddrFormatTypeType", "ref_uuid" => "aef85109-fdfd-4902-aa58-8fca4332992d", "name" => "AddrFormatType", "label" => "AddrFormatTypeType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["Label", "Label"], ["Parsed", "Parsed"]]}, {"maxLength" => 80, "name" => "AddrFormatTypeEnumDesc", "hint" => "Address Format Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 130, "name" => "FullName1", "hint" => "Full Name Line 1.Value should not be more than 130 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 130, "name" => "FullName2", "hint" => "Full Name Line 2.Value should not be more than 130 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 130, "name" => "FullName3", "hint" => "Full Name Line 3.Value should not be more than 130 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr1", "hint" => "Address Line 1.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr2", "hint" => "Address Line 2.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr3", "hint" => "Address Line 3.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr4", "hint" => "Address Line 4.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr5", "hint" => "Address Line 5.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr6", "hint" => "Address Line 6.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 15, "name" => "ApartmentNum", "hint" => "Apartment Number.Value should not be more than 15 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "ApartmentNumType", "hint" => "Apartment Number Type. This is an identifier of the type of number provided in the Apartment Number field.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 15, "name" => "HouseNum", "hint" => "House Number.Value should not be more than 15 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Street", "hint" => "Street.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"maxLength" => 64, "name" => "Addr1", "hint" => "Address Line 1.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr2", "hint" => "Address Line 2.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr3", "hint" => "Address Line 3.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr4", "hint" => "Address Line 4.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr5", "hint" => "Address Line 5.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr6", "hint" => "Address Line 6.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "LabelAddrType", "ref_uuid" => "0347186e-357a-4583-b601-1a8c62fd7322", "name" => "LabelAddr", "label" => "LabelAddrType", "type" => "object"}, {"name" => "AddrDefinedData", "hint" => "Address Defined Data.", "of" => "object", "properties" => [{"maxLength" => 36, "name" => "DataIdent", "optional" => false, "hint" => "Data Identification. Identification of the client defined data item.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 256, "name" => "Value", "hint" => "Value string representation of the EFX data value of the element in error. This field is intended to provide a human readable visual hint as to the value in error. It should not be provided for fields that cannot be represented as a string (i.e., binary data).Value should not be more than 256 characters. ", "control_type" => "text", "type" => "string"}], "type" => "array"}, {"maxLength" => 64, "name" => "HouseName", "hint" => "House Name.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 40, "name" => "City", "hint" => "City.Value should not be more than 40 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 32, "name" => "County", "hint" => "County.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 32, "name" => "District", "hint" => "District.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "StateProv", "hint" => "State/Province. ISO 3166-2:US codes.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "StateProvEnumDesc", "hint" => "State Province Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "MilitaryRegion", "hint" => "Military Region. Identifier that replaces State and City for military addressesValue should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 11, "name" => "PostalCode", "hint" => "Postal Code. ZipCode in the US.Value should not be more than 11 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Country", "hint" => "Country.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"maxLength" => 80, "name" => "CountryCodeSource", "hint" => "Country Code Source. Used with CountryCodeValue to indicate the Country Code Source table.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValue", "optional" => false, "hint" => "Country Code Value. Indicates the Country Code Value within the CountryCodeSource table specified.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValueEnumDesc", "hint" => "Country Code Value Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "CountryCodeType", "ref_uuid" => "32e77c00-d11f-4ed8-8d37-00a8adb59575", "name" => "CountryCode", "label" => "CountryCodeType", "type" => "object"}, {"maxLength" => 16, "name" => "POBox", "hint" => "PO Box.Value should not be more than 16 characters. ", "control_type" => "text", "type" => "string"}, {"object_ref_name" => "AddrTypeType", "ref_uuid" => "2243dd80-66b0-4531-b543-1cb6dd0ed6ef", "name" => "AddrType", "optional" => false, "label" => "AddrTypeType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["Primary", "Primary"], ["PrimaryPending", "PrimaryPending"], ["Secondary", "Secondary"], ["Seasonal", "Seasonal"], ["Previous", "Previous"], ["Physical", "Physical"]]}, {"maxLength" => 80, "name" => "AddrTypeEnumDesc", "hint" => "Address Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PreferredAddr", "hint" => "Indicates the address is the preferred address.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 255, "name" => "AddrLocation", "hint" => "Address Location. Indicates if the address location is a Business or Home.Value should not be more than 255 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "AddrLocationEnumDesc", "hint" => "Address Location Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "StartDt", "hint" => "Start Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"object_ref_name" => "DayOfMonthType", "ref_uuid" => "5824515d-bb1c-4414-9b58-1c8fdee789ff", "name" => "DayOfMonth", "label" => "DayOfMonthType", "control_type" => "select", "type" => "integer", "extends_schema" => true, "pick_list" => [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [8, 8], [9, 9], [10, 10], [11, 11], [12, 12], [13, 13], [14, 14], [15, 15], [16, 16], [17, 17], [18, 18], [19, 19], [20, 20], [21, 21], [22, 22], [23, 23], [24, 24], [25, 25], [26, 26], [27, 27], [28, 28], [29, 29], [30, 30], [31, 31]]}, {"name" => "Month", "hint" => "Month. Numeric value representing the month of recurrence. Valid values: integers between 1 and 12 inclusive.", "control_type" => "integer", "type" => "integer"}], "object_ref_name" => "StartDayMonthType", "ref_uuid" => "31c69a60-a079-4489-ba3d-6bbf7e33b16d", "name" => "StartDayMonth", "label" => "StartDayMonthType", "type" => "object"}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "EndDt", "hint" => "End Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"object_ref_name" => "DayOfMonthType", "ref_uuid" => "5824515d-bb1c-4414-9b58-1c8fdee789ff", "name" => "DayOfMonth", "label" => "DayOfMonthType", "control_type" => "select", "type" => "integer", "extends_schema" => true, "pick_list" => [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [8, 8], [9, 9], [10, 10], [11, 11], [12, 12], [13, 13], [14, 14], [15, 15], [16, 16], [17, 17], [18, 18], [19, 19], [20, 20], [21, 21], [22, 22], [23, 23], [24, 24], [25, 25], [26, 26], [27, 27], [28, 28], [29, 29], [30, 30], [31, 31]]}, {"name" => "Month", "hint" => "Month. Numeric value representing the month of recurrence. Valid values: integers between 1 and 12 inclusive.", "control_type" => "integer", "type" => "integer"}], "object_ref_name" => "StartDayMonthType", "ref_uuid" => "b606cc2b-961d-4bc3-a7f0-7aeb1e7587d5", "name" => "EndDayMonth", "label" => "StartDayMonthType", "type" => "object"}, {"properties" => [{"name" => "Count", "hint" => "Count. Sometimes specifies the duration of the time frame base on the units specified.", "control_type" => "integer", "type" => "integer"}, {"maxLength" => 80, "name" => "Unit", "hint" => "Unit.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "UnitEnumDesc", "hint" => "Unit Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "DurationType", "ref_uuid" => "147b2ed6-500d-4c23-b639-228453d0f607", "name" => "Duration", "label" => "DurationType", "type" => "object"}, {"name" => "RecurRule", "hint" => "Recurrence Rule.", "of" => "object", "properties" => [{"maxLength" => 80, "name" => "RecurType", "hint" => "Recurrence Type. Indicates the pattern of recurrence.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "RecurTypeEnumDesc", "hint" => "Recurrence Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "RecurInterval", "hint" => "Recurrence Interval. Number of units between occurrences. Should be an integer. If  ‘Daily’: Number of days between occurrences. If   ‘Weekly’: Number of weeks between occurrences. If   'Monthly’: Number of months between occurrences. If   ‘Yearly’: Number of years between occurrences. If not provided, assume default value of 1, i.e. every day, every week, every month, or every year. If 'Cycle' => Number of the designated cycle.", "control_type" => "integer", "type" => "integer"}, {"name" => "RecurInstance", "hint" => "Recurrent Instance. Numeric value representing the instance of the days(s) of the week of recurrence, i.e. Second Wednesday of the month, First Monday of the year. DayOfWeek must also be provided.", "control_type" => "integer", "type" => "integer"}, {"object_ref_name" => "DayOfWeekType", "ref_uuid" => "75435137-bbcd-4db6-83f6-3f693408d0de", "name" => "DayOfWeek", "label" => "DayOfWeekType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["Monday", "Monday"], ["Tuesday", "Tuesday"], ["Wednesday", "Wednesday"], ["Thursday", "Thursday"], ["Friday", "Friday"], ["Saturday", "Saturday"], ["Sunday", "Sunday"]]}, {"object_ref_name" => "DayOfMonthType", "ref_uuid" => "9d674865-3ebe-43ce-9c7e-34ae08e47fd6", "name" => "DayOfMonth", "label" => "DayOfMonthType", "control_type" => "select", "type" => "integer", "extends_schema" => true, "pick_list" => [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [8, 8], [9, 9], [10, 10], [11, 11], [12, 12], [13, 13], [14, 14], [15, 15], [16, 16], [17, 17], [18, 18], [19, 19], [20, 20], [21, 21], [22, 22], [23, 23], [24, 24], [25, 25], [26, 26], [27, 27], [28, 28], [29, 29], [30, 30], [31, 31]]}, {"object_ref_name" => "DayOfMonthType", "ref_uuid" => "951543ec-72d3-4d78-aca9-230344b501b0", "name" => "SecondDayOfMonth", "label" => "DayOfMonthType", "control_type" => "select", "type" => "integer", "extends_schema" => true, "pick_list" => [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [8, 8], [9, 9], [10, 10], [11, 11], [12, 12], [13, 13], [14, 14], [15, 15], [16, 16], [17, 17], [18, 18], [19, 19], [20, 20], [21, 21], [22, 22], [23, 23], [24, 24], [25, 25], [26, 26], [27, 27], [28, 28], [29, 29], [30, 30], [31, 31]]}, {"name" => "Month", "hint" => "Month. Numeric value representing the month of recurrence. Valid values: integers between 1 and 12 inclusive.", "control_type" => "integer", "type" => "integer"}, {"name" => "RecurStartDate", "hint" => "Recurrence Start Date.", "control_type" => "date", "type" => "date"}, {"name" => "Occurrences", "hint" => "Occurrences.", "control_type" => "integer", "type" => "integer"}, {"name" => "RecurEndDate", "hint" => "Recurrence End Date.", "control_type" => "date", "type" => "date"}, {"name" => "LeadDays", "hint" => "Lead Days. Number of days prior to a specified date.", "control_type" => "integer", "type" => "integer"}, {"name" => "AdjDays", "hint" => "Adjustment Days. Indicates the number of days to adjust a value (review a rate or perform interest accrual) after an event occurs (see AdjDaysBasis).", "control_type" => "integer", "type" => "integer"}, {"maxLength" => 80, "name" => "AdjDaysBasis", "hint" => "Adjustment Days Basis. Used in combination with Adjustment Days (AdjDays). It indicates a basis for an adjustment such as: Due Date (DueDt), Statement Date (StmtDt).Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "WeekendOption", "hint" => "Weekend Option. Describes how certain functionality, e.g. Transfers are processed on the Weekend.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "WeekendOptionEnumDesc", "hint" => "WeekendOption Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "type" => "array"}], "object_ref_name" => "TimeFrameType", "ref_uuid" => "1fe45ad8-ec76-45c3-ac22-1ccb2d834ab2", "name" => "TimeFrame", "label" => "TimeFrameType", "type" => "object"}, {"name" => "ExpDt", "hint" => "Expiration Date.", "control_type" => "date", "type" => "date"}, {"name" => "Retention", "hint" => "Retention. Indicates whether the records are to be retained or deleted based on Service Provider criteria.", "control_type" => "checkbox", "type" => "boolean"}, {"name" => "RevertToPartyAddr", "hint" => "Revert to Party Address. Indicates for account alternate addresses if the address must be reverted to the Party name and address.", "control_type" => "checkbox", "type" => "boolean"}, {"name" => "MoveInDt", "hint" => "Move In Date.", "control_type" => "date", "type" => "date"}, {"maxLength" => 80, "name" => "ContactMethod", "hint" => "Contact Method.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "UpDt", "hint" => "Update Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 300, "name" => "Comment", "hint" => "Comment. A comment entered in history.Value should not be more than 300 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 20, "name" => "CensusTract", "hint" => "Census Track. Contains the census tract number assigned to the address.Value should not be more than 20 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 20, "name" => "CensusBlock", "hint" => "Census Block. Contains the census block group designation for the block where the address is within a census tract.Value should not be more than 20 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "ForeignFlag", "hint" => "Foreign Flag. Indicator that tells if an item (an address for example) is foreign or not.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 80, "name" => "HandlingCode", "hint" => "Handling Code .Indicates special handling of notification and statement forms.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "HandlingCodeEnumDesc", "hint" => "Handling Code Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"object_ref_name" => "HandlingCodeOptionType", "ref_uuid" => "b3d9f98a-e9b2-4c68-a382-9d1000e17e36", "name" => "HandlingCodeOption", "label" => "HandlingCodeOptionType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["StatementsNoticesChecks", "StatementsNoticesChecks"], ["Statements", "Statements"], ["StatementsNotices", "StatementsNotices"], ["StatementsChecks", "StatementsChecks"], ["Notices", "Notices"], ["NoticesChecks", "NoticesChecks"], ["Checks", "Checks"], ["DoNotPrint", "DoNotPrint"], ["UsePortfolio", "UsePortfolio"], ["UseDefault", "UseDefault"]]}, {"maxLength" => 80, "name" => "HandlingCodeOptionEnumDesc", "hint" => "Handling Code Option Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "MSACode", "hint" => "MSA Code. MSAs are defined by the U.S. Office of Management and Budget (OMB), and used by the U.S. Census Bureau and other federal government agencies for statistical purposes", "control_type" => "integer", "type" => "integer"}, {"maxLength" => 80, "name" => "MSACodeEnumDesc", "hint" => "MSA Code Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "MaintDt", "hint" => "Maintenance Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "MaintBy", "hint" => "Maintained By.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "MaintByEnumDesc", "hint" => "Maintained By Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "AddrInUseInd", "hint" => "Address In Use.", "control_type" => "checkbox", "type" => "boolean"}, {"name" => "PhoneNum", "hint" => "Phone Number.", "of" => "object", "properties" => [{"maxLength" => 80, "name" => "PhoneType", "optional" => false, "hint" => "Phone Type.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PhoneTypeEnumDesc", "hint" => "Phone Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PhoneIdent", "hint" => "Phone Identifier. Use when you have more than one occurrence of a phone type  (for example 5 Mobile phones). This element serializes the phones.", "control_type" => "integer", "type" => "integer"}, {"name" => "Phone", "hint" => "Phone.", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PhoneExchange", "hint" => "Phone Exchange.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PreferredPhone", "hint" => "Preferred Phone.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 10, "name" => "Priority", "hint" => "Priority Code.Value should not be more than 10 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "DoNotContactInd", "hint" => "Do Not Contact Indicator.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 30, "name" => "PhoneDesc", "hint" => "Phone Description.Value should not be more than 30 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"maxLength" => 80, "name" => "CountryCodeSource", "hint" => "Country Code Source. Used with CountryCodeValue to indicate the Country Code Source table.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValue", "optional" => false, "hint" => "Country Code Value. Indicates the Country Code Value within the CountryCodeSource table specified.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValueEnumDesc", "hint" => "Country Code Value Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "CountryCodeType", "ref_uuid" => "ee56204d-5b19-4df8-bb91-5caef4d17f78", "name" => "CountryCode", "label" => "CountryCodeType", "type" => "object"}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "UpDt", "hint" => "Update Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}], "type" => "array"}, {"name" => "InvalidAddrInd", "hint" => "Indicates that the address has been identified as a not viable method to contact the customer. ", "control_type" => "checkbox", "type" => "boolean"}, {"name" => "IncAddrFormat", "control_type" => "checkbox", "type" => "boolean"}], "name" => "PostAddr", "type" => "object"}, {"properties" => [{"maxLength" => 36, "name" => "EmailIdent", "hint" => "Email Identification.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "EmailType", "hint" => "Email Type. Indicates the type of email address.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "EmailTypeEnumDesc", "hint" => "Email Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 254, "name" => "EmailAddr", "hint" => "Email Address.Value should not be more than 254 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PreferredEmail", "hint" => "Preferred Email.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 10, "name" => "Priority", "hint" => "Priority Code.Value should not be more than 10 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "EmailType", "ref_uuid" => "4f4bad2d-0c9f-4dc8-a8fa-0fef2b3ad616", "name" => "Email", "label" => "EmailType", "type" => "object"}, {"properties" => [{"name" => "WebAddrIdent", "hint" => "Web Address Identifier. Use when you have more than one occurrence of a web address type. This element serializes the web addresses.", "control_type" => "integer", "type" => "integer"}, {"maxLength" => 80, "name" => "WebAddrType", "hint" => "Web Address Type.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "WebAddrTypeEnumDesc", "hint" => "Web Address Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 1024, "name" => "WebAddrLink", "hint" => "Web Address Link.Value should not be more than 1024 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PreferredWebAddr", "hint" => "Preferred Web Address.", "control_type" => "checkbox", "type" => "boolean"}], "object_ref_name" => "WebAddrType", "ref_uuid" => "4d1bee84-2ab5-48d1-8b00-cd857be1ff99", "name" => "WebAddr", "label" => "WebAddrType", "type" => "object"}, {"maxLength" => 36, "name" => "ContactIdent", "hint" => "Contact Identifier. Refers to a customer number if the contact is a customer in the customer file.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 40, "name" => "ContactName", "hint" => "Contact. Contact Name.Value should not be more than 40 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 32, "name" => "ContactTitle", "hint" => "Contact Job Title.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "DoNotSolicitInd", "hint" => "Do Not Solicit Indicator. Use to determine whether contact information can be used for solicitation.", "control_type" => "checkbox", "type" => "boolean"}], "type" => "array"}, {"object_ref_name" => "TaxIdentTypeType", "ref_uuid" => "245e0119-3138-448c-935f-e492978473a6", "name" => "TaxIdentType", "label" => "TaxIdentTypeType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["None", "None"], ["SSN", "SSN"], ["EIN", "EIN"], ["Foreign", "Foreign"], ["ITIN", "ITIN"], ["ATIN", "ATIN"], ["Other", "Other"]]}, {"maxLength" => 80, "name" => "TaxIdentTypeEnumDesc", "hint" => "Tax Identification Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 12, "name" => "TaxIdent", "hint" => "Tax Identification.Value should not be more than 12 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "TaxIdentApplyDt", "hint" => "Tax Identifier Application Date.", "control_type" => "date", "type" => "date"}, {"name" => "IssuedIdent", "hint" => "Issued Identification. Used to include issued identifications. If the identification is government issued, the GovIssuedIdent aggregate must be included.", "of" => "object", "properties" => [{"maxLength" => 80, "name" => "IssuedIdentType", "optional" => false, "hint" => "Issued Identification Type. Valid values: DrvrsLicNb, BirthCertificate, HealthCard, Military, AlnRegnNb, IdntyCardNb, VoterRegistration, PsptNb, MplyrIdNb, TaxIdNb,  SclSctyNb, NRAPersonal, NRABusiness, Other.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "IssuedIdentTypeEnumDesc", "hint" => "Issued Identification Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 36, "name" => "IssuedIdentId", "hint" => "Issued Identification Id.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 50, "name" => "IssuedIdentValue", "hint" => "Issued Identification Value. Identification value associated with the identification type.Value should not be more than 50 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 32, "name" => "Issuer", "hint" => "Issuer.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "IssuerEnumDesc", "hint" => "Issuer Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "IssuerLocation", "hint" => "Issuer Location.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "IssuerLocationEnumDesc", "hint" => "Issuer Location Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "IssueDt", "hint" => "Issue Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}, {"name" => "ExpDt", "hint" => "Expiration Date.", "control_type" => "date", "type" => "date"}, {"name" => "IdentVerifyDt", "hint" => "Identification Verification Date.", "control_type" => "date", "type" => "date"}, {"name" => "NextIdentVerifyDt", "hint" => "Next Identification Verification Date.", "control_type" => "date", "type" => "date"}, {"maxLength" => 255, "name" => "VerificationDetailText", "hint" => "Verification Detail Text.Value should not be more than 255 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"properties" => [{"maxLength" => 80, "name" => "CountryCodeSource", "hint" => "Country Code Source. Used with CountryCodeValue to indicate the Country Code Source table.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValue", "optional" => false, "hint" => "Country Code Value. Indicates the Country Code Value within the CountryCodeSource table specified.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValueEnumDesc", "hint" => "Country Code Value Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "CountryCodeType", "ref_uuid" => "027add40-2d2e-45de-af66-d72f061c0a13", "name" => "CountryCode", "optional" => false, "label" => "CountryCodeType", "type" => "object"}, {"maxLength" => 80, "name" => "StateProv", "hint" => "State/Province. ISO 3166-2:US codes.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "StateProvEnumDesc", "hint" => "State Province Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "GovIssuedIdentType", "ref_uuid" => "b5996092-167b-4705-9e05-e37cab98fac7", "name" => "GovIssuedIdent", "label" => "GovIssuedIdentType", "type" => "object"}], "type" => "array"}, {"name" => "OEDCode", "hint" => "Officer, Employee, DIrector Code. Indicates if the party is an employee of the Bank."}, {"maxLength" => 80, "name" => "OEDCodeEnumDesc", "hint" => "Officer Employee Director Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "EmployeeInd", "hint" => "Employee Indicator. Indicates that the account holder is employee of the FI.", "control_type" => "checkbox", "type" => "boolean"}, {"name" => "RestrictedInd", "hint" => "Restricted Indicator. Indicates whether the account information is restricted for view by the requester.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 80, "name" => "RestrictedDesc", "hint" => "Restricted Description. Description of the reason for the account to be restricted.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "SecretData", "hint" => "Secret Data.", "of" => "object", "properties" => [{"maxLength" => 80, "name" => "SecretIdent", "hint" => "Secret Identifier.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "SecretIdentEnumDesc", "hint" => "Secret Identifier Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "SecretValue", "hint" => "Secret Value.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "type" => "array"}, {"maxLength" => 32, "name" => "OriginatingBranch", "hint" => "Originating Branch. Branch first originated the relationship with party or created the account.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "OriginatingBranchEnumDesc", "hint" => "Originating Branch Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "ServiceLevel", "hint" => "Service Level. Indicates the level of service or the type of pricing that the customer should receiveValue should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "ServiceLevelEnumDesc", "hint" => "Service Level Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "MarketSegment", "hint" => "Party Market Segment.  Value that the institution can can use to enter marketing information for this customer.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "MarketSegmentEnumDesc", "hint" => "Party Market Segment Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 255, "name" => "TelebancPswd", "hint" => "Telebanc Password. The Electronic Banking Password is the number used for personal identification when accessing information in Connect3.Value should not be more than 255 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 10, "name" => "SocioEconomicCode", "hint" => "Socio Economic Code.Value should not be more than 10 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "SocioEconomicCodeEnumDesc", "hint" => "Socio Economic Code Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"object_ref_name" => "NameTypeType", "ref_uuid" => "7a2cf625-d2a2-4fa6-9fc2-fbab418cc891", "name" => "NameType", "optional" => false, "label" => "NameTypeType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["Primary", "Primary"], ["Secondary", "Secondary"], ["Legal", "Legal"]]}, {"maxLength" => 80, "name" => "NameTypeEnumDesc", "hint" => "Name Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 36, "name" => "NameIdent", "hint" => "Name Identifier.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 130, "name" => "FullName", "hint" => "Full Name.Value should not be more than 130 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 60, "name" => "FamilyName", "hint" => "Family Name.Value should not be more than 60 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 60, "name" => "GivenName", "hint" => "Given Name. Person's first name.Value should not be more than 60 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 60, "name" => "MiddleName", "hint" => "Middle Name. Person's middle name.Value should not be more than 60 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "NamePrefix", "hint" => "Name Prefix. Identifies a title before a person's name.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "NameSuffix", "hint" => "Name Suffix. For example, “Ms.”, or “Dr.”Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 96, "name" => "PreferredName", "hint" => "Preferred Name or Nickname.  For example, person is requesting to be called 'Tony' instead of 'Anthony'.Value should not be more than 96 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 96, "name" => "LegalName", "hint" => "Legal Name. Legal Name of the Organization.Value should not be more than 96 characters. ", "control_type" => "text", "type" => "string"}, {"object_ref_name" => "NameFormatType", "ref_uuid" => "73aec087-23bd-4a3e-8ff7-c6a7c9f94279", "name" => "NameFormat", "label" => "NameFormatType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["None", "None"], ["NonPersonal", "NonPersonal"], ["FirstLastSuffix", "FirstLastSuffix"], ["FirstMiddleInitialLastSuffix", "FirstMiddleInitialLastSuffix"], ["FirstMiddleLastSuffix", "FirstMiddleLastSuffix"], ["PrintedMailingSeasonal", "PrintedMailingSeasonal"], ["PrintedMailingSeasonalTax", "PrintedMailingSeasonalTax"], ["PrintedSeasonalOnly", "PrintedSeasonalOnly"], ["PrintedAddressOnly", "PrintedAddressOnly"]]}, {"maxLength" => 80, "name" => "NameFormatEnumDesc", "hint" => "Name Format Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "NameInUseInd", "hint" => "Name In Use Indicator.", "control_type" => "checkbox", "type" => "boolean"}], "object_ref_name" => "PersonNameType", "ref_uuid" => "ad3f89a4-8af4-4576-ac05-e3e7354086d3", "name" => "PersonName", "label" => "PersonNameType", "type" => "object"}, {"name" => "BirthDt", "hint" => "Birth Date.", "control_type" => "date", "type" => "date"}], "object_ref_name" => "PersonPartyListInfoType", "ref_uuid" => "27b2ee01-a0aa-4216-be86-2896fa8acaa4", "label" => "PersonPartyListInfoType", "hint" => "Party Information.", "name" => "PersonPartyListInfo", "type" => "object"}, {"properties" => [{"properties" => [{"maxLength" => 80, "name" => "MemberGroup", "hint" => "Member Group.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 36, "name" => "MemberNum", "hint" => "Member Number.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "MemberDataType", "ref_uuid" => "9eca2c6b-3b8f-4db3-816c-9d14229f9221", "name" => "MemberData", "label" => "MemberDataType", "hint" => "Member Data.", "type" => "object"}, {"maxLength" => 80, "name" => "PartySelType", "hint" => "Party Selection Type.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PartyType", "hint" => "Party Type.Used to further specify the type of Party.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PartyTypeEnumDesc", "hint" => "Party Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "Contact", "hint" => "Contact. This aggregate contains a person's or organization's contact information", "of" => "object", "properties" => [{"properties" => [{"maxLength" => 80, "name" => "PhoneType", "optional" => false, "hint" => "Phone Type.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PhoneTypeEnumDesc", "hint" => "Phone Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PhoneIdent", "hint" => "Phone Identifier. Use when you have more than one occurrence of a phone type  (for example 5 Mobile phones). This element serializes the phones.", "control_type" => "integer", "type" => "integer"}, {"name" => "Phone", "hint" => "Phone.", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PhoneExchange", "hint" => "Phone Exchange.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PreferredPhone", "hint" => "Preferred Phone.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 10, "name" => "Priority", "hint" => "Priority Code.Value should not be more than 10 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "DoNotContactInd", "hint" => "Do Not Contact Indicator.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 30, "name" => "PhoneDesc", "hint" => "Phone Description.Value should not be more than 30 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"maxLength" => 80, "name" => "CountryCodeSource", "hint" => "Country Code Source. Used with CountryCodeValue to indicate the Country Code Source table.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValue", "optional" => false, "hint" => "Country Code Value. Indicates the Country Code Value within the CountryCodeSource table specified.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValueEnumDesc", "hint" => "Country Code Value Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "CountryCodeType", "ref_uuid" => "ee56204d-5b19-4df8-bb91-5caef4d17f78", "name" => "CountryCode", "label" => "CountryCodeType", "type" => "object"}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "UpDt", "hint" => "Update Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "PhoneNumType", "ref_uuid" => "052f5504-7bc7-49ce-bb50-4963d4db62e5", "name" => "PhoneNum", "label" => "PhoneNumType", "type" => "object"}, {"object_ref_name" => "PostAddrType", "ref_uuid" => "6fefb81c-9e7f-4858-a982-c24314da039c", "label" => "PostAddrType", "properties" => [{"name" => "OpenDt", "hint" => "Open Date.", "control_type" => "date", "type" => "date"}, {"name" => "RelationshipMgr", "hint" => "Relationship Manager. Stores information about the FI officers that have management responsibility of the Party, the Account or the Card.", "of" => "object", "properties" => [{"maxLength" => 36, "name" => "RelationshipMgrIdent", "optional" => false, "hint" => "Relationship Manager Identifier. Identifies officer/employee of financial institution.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "RelationshipMgrIdentEnumDesc", "hint" => "Relationship Manager Identifier Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"object_ref_name" => "RelationshipRoleType", "ref_uuid" => "48cc411f-cfe1-490c-9bad-9c787340da3d", "name" => "RelationshipRole", "label" => "RelationshipRoleType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["Officer", "Officer"], ["SecondOfficer", "SecondOfficer"], ["ThirdOfficer", "ThirdOfficer"], ["FourthOfficer", "FourthOfficer"], ["ReferralOfficer", "ReferralOfficer"]]}, {"maxLength" => 80, "name" => "RelationshipRoleEnumDesc", "hint" => "Relationship Role Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "type" => "array"}, {"maxLength" => 32, "name" => "OriginatingBranch", "hint" => "Originating Branch. Branch first originated the relationship with party or created the account.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "OriginatingBranchEnumDesc", "hint" => "Originating Branch Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 32, "name" => "PreferredBranch", "hint" => "Preferred Branch. The branch preferred by the customer to conduct business.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PreferredBranchEnumDesc", "hint" => "Preferred Branch Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 32, "name" => "ResponsibleBranch", "hint" => "Responsible Branch. Branch responsible for the relationship.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "ResponsibleBranchEnumDesc", "hint" => "Responsible Branch Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "NameIdent", "hint" => "Name Identifier.", "of" => "string", "type" => "array"}, {"maxLength" => 36, "name" => "AddressIdent", "hint" => "Address Identification. Used as pointer to a reference of an address. Other identification used as part of the Address object key.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "AddrUse", "hint" => "Address Use. Indicates the use of the address for example Business or Home, Statement, Check, Government, etc.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "AddrUseEnumDesc", "hint" => "Address Use  Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"object_ref_name" => "AddrFormatTypeType", "ref_uuid" => "aef85109-fdfd-4902-aa58-8fca4332992d", "name" => "AddrFormatType", "label" => "AddrFormatTypeType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["Label", "Label"], ["Parsed", "Parsed"]]}, {"maxLength" => 80, "name" => "AddrFormatTypeEnumDesc", "hint" => "Address Format Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 130, "name" => "FullName1", "hint" => "Full Name Line 1.Value should not be more than 130 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 130, "name" => "FullName2", "hint" => "Full Name Line 2.Value should not be more than 130 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 130, "name" => "FullName3", "hint" => "Full Name Line 3.Value should not be more than 130 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr1", "hint" => "Address Line 1.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr2", "hint" => "Address Line 2.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr3", "hint" => "Address Line 3.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr4", "hint" => "Address Line 4.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr5", "hint" => "Address Line 5.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr6", "hint" => "Address Line 6.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 15, "name" => "ApartmentNum", "hint" => "Apartment Number.Value should not be more than 15 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "ApartmentNumType", "hint" => "Apartment Number Type. This is an identifier of the type of number provided in the Apartment Number field.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 15, "name" => "HouseNum", "hint" => "House Number.Value should not be more than 15 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Street", "hint" => "Street.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"maxLength" => 64, "name" => "Addr1", "hint" => "Address Line 1.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr2", "hint" => "Address Line 2.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr3", "hint" => "Address Line 3.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr4", "hint" => "Address Line 4.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr5", "hint" => "Address Line 5.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Addr6", "hint" => "Address Line 6.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "LabelAddrType", "ref_uuid" => "0347186e-357a-4583-b601-1a8c62fd7322", "name" => "LabelAddr", "label" => "LabelAddrType", "type" => "object"}, {"name" => "AddrDefinedData", "hint" => "Address Defined Data.", "of" => "object", "properties" => [{"maxLength" => 36, "name" => "DataIdent", "optional" => false, "hint" => "Data Identification. Identification of the client defined data item.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 256, "name" => "Value", "hint" => "Value string representation of the EFX data value of the element in error. This field is intended to provide a human readable visual hint as to the value in error. It should not be provided for fields that cannot be represented as a string (i.e., binary data).Value should not be more than 256 characters. ", "control_type" => "text", "type" => "string"}], "type" => "array"}, {"maxLength" => 64, "name" => "HouseName", "hint" => "House Name.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 40, "name" => "City", "hint" => "City.Value should not be more than 40 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 32, "name" => "County", "hint" => "County.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 32, "name" => "District", "hint" => "District.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "StateProv", "hint" => "State/Province. ISO 3166-2:US codes.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "StateProvEnumDesc", "hint" => "State Province Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "MilitaryRegion", "hint" => "Military Region. Identifier that replaces State and City for military addressesValue should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 11, "name" => "PostalCode", "hint" => "Postal Code. ZipCode in the US.Value should not be more than 11 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 64, "name" => "Country", "hint" => "Country.Value should not be more than 64 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"maxLength" => 80, "name" => "CountryCodeSource", "hint" => "Country Code Source. Used with CountryCodeValue to indicate the Country Code Source table.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValue", "optional" => false, "hint" => "Country Code Value. Indicates the Country Code Value within the CountryCodeSource table specified.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValueEnumDesc", "hint" => "Country Code Value Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "CountryCodeType", "ref_uuid" => "32e77c00-d11f-4ed8-8d37-00a8adb59575", "name" => "CountryCode", "label" => "CountryCodeType", "type" => "object"}, {"maxLength" => 16, "name" => "POBox", "hint" => "PO Box.Value should not be more than 16 characters. ", "control_type" => "text", "type" => "string"}, {"object_ref_name" => "AddrTypeType", "ref_uuid" => "2243dd80-66b0-4531-b543-1cb6dd0ed6ef", "name" => "AddrType", "optional" => false, "label" => "AddrTypeType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["Primary", "Primary"], ["PrimaryPending", "PrimaryPending"], ["Secondary", "Secondary"], ["Seasonal", "Seasonal"], ["Previous", "Previous"], ["Physical", "Physical"]]}, {"maxLength" => 80, "name" => "AddrTypeEnumDesc", "hint" => "Address Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PreferredAddr", "hint" => "Indicates the address is the preferred address.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 255, "name" => "AddrLocation", "hint" => "Address Location. Indicates if the address location is a Business or Home.Value should not be more than 255 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "AddrLocationEnumDesc", "hint" => "Address Location Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "StartDt", "hint" => "Start Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"object_ref_name" => "DayOfMonthType", "ref_uuid" => "5824515d-bb1c-4414-9b58-1c8fdee789ff", "name" => "DayOfMonth", "label" => "DayOfMonthType", "control_type" => "select", "type" => "integer", "extends_schema" => true, "pick_list" => [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [8, 8], [9, 9], [10, 10], [11, 11], [12, 12], [13, 13], [14, 14], [15, 15], [16, 16], [17, 17], [18, 18], [19, 19], [20, 20], [21, 21], [22, 22], [23, 23], [24, 24], [25, 25], [26, 26], [27, 27], [28, 28], [29, 29], [30, 30], [31, 31]]}, {"name" => "Month", "hint" => "Month. Numeric value representing the month of recurrence. Valid values: integers between 1 and 12 inclusive.", "control_type" => "integer", "type" => "integer"}], "object_ref_name" => "StartDayMonthType", "ref_uuid" => "31c69a60-a079-4489-ba3d-6bbf7e33b16d", "name" => "StartDayMonth", "label" => "StartDayMonthType", "type" => "object"}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "EndDt", "hint" => "End Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"object_ref_name" => "DayOfMonthType", "ref_uuid" => "5824515d-bb1c-4414-9b58-1c8fdee789ff", "name" => "DayOfMonth", "label" => "DayOfMonthType", "control_type" => "select", "type" => "integer", "extends_schema" => true, "pick_list" => [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [8, 8], [9, 9], [10, 10], [11, 11], [12, 12], [13, 13], [14, 14], [15, 15], [16, 16], [17, 17], [18, 18], [19, 19], [20, 20], [21, 21], [22, 22], [23, 23], [24, 24], [25, 25], [26, 26], [27, 27], [28, 28], [29, 29], [30, 30], [31, 31]]}, {"name" => "Month", "hint" => "Month. Numeric value representing the month of recurrence. Valid values: integers between 1 and 12 inclusive.", "control_type" => "integer", "type" => "integer"}], "object_ref_name" => "StartDayMonthType", "ref_uuid" => "b606cc2b-961d-4bc3-a7f0-7aeb1e7587d5", "name" => "EndDayMonth", "label" => "StartDayMonthType", "type" => "object"}, {"properties" => [{"name" => "Count", "hint" => "Count. Sometimes specifies the duration of the time frame base on the units specified.", "control_type" => "integer", "type" => "integer"}, {"maxLength" => 80, "name" => "Unit", "hint" => "Unit.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "UnitEnumDesc", "hint" => "Unit Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "DurationType", "ref_uuid" => "147b2ed6-500d-4c23-b639-228453d0f607", "name" => "Duration", "label" => "DurationType", "type" => "object"}, {"name" => "RecurRule", "hint" => "Recurrence Rule.", "of" => "object", "properties" => [{"maxLength" => 80, "name" => "RecurType", "hint" => "Recurrence Type. Indicates the pattern of recurrence.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "RecurTypeEnumDesc", "hint" => "Recurrence Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "RecurInterval", "hint" => "Recurrence Interval. Number of units between occurrences. Should be an integer. If  ‘Daily’: Number of days between occurrences. If   ‘Weekly’: Number of weeks between occurrences. If   'Monthly’: Number of months between occurrences. If   ‘Yearly’: Number of years between occurrences. If not provided, assume default value of 1, i.e. every day, every week, every month, or every year. If 'Cycle' => Number of the designated cycle.", "control_type" => "integer", "type" => "integer"}, {"name" => "RecurInstance", "hint" => "Recurrent Instance. Numeric value representing the instance of the days(s) of the week of recurrence, i.e. Second Wednesday of the month, First Monday of the year. DayOfWeek must also be provided.", "control_type" => "integer", "type" => "integer"}, {"object_ref_name" => "DayOfWeekType", "ref_uuid" => "75435137-bbcd-4db6-83f6-3f693408d0de", "name" => "DayOfWeek", "label" => "DayOfWeekType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["Monday", "Monday"], ["Tuesday", "Tuesday"], ["Wednesday", "Wednesday"], ["Thursday", "Thursday"], ["Friday", "Friday"], ["Saturday", "Saturday"], ["Sunday", "Sunday"]]}, {"object_ref_name" => "DayOfMonthType", "ref_uuid" => "9d674865-3ebe-43ce-9c7e-34ae08e47fd6", "name" => "DayOfMonth", "label" => "DayOfMonthType", "control_type" => "select", "type" => "integer", "extends_schema" => true, "pick_list" => [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [8, 8], [9, 9], [10, 10], [11, 11], [12, 12], [13, 13], [14, 14], [15, 15], [16, 16], [17, 17], [18, 18], [19, 19], [20, 20], [21, 21], [22, 22], [23, 23], [24, 24], [25, 25], [26, 26], [27, 27], [28, 28], [29, 29], [30, 30], [31, 31]]}, {"object_ref_name" => "DayOfMonthType", "ref_uuid" => "951543ec-72d3-4d78-aca9-230344b501b0", "name" => "SecondDayOfMonth", "label" => "DayOfMonthType", "control_type" => "select", "type" => "integer", "extends_schema" => true, "pick_list" => [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [8, 8], [9, 9], [10, 10], [11, 11], [12, 12], [13, 13], [14, 14], [15, 15], [16, 16], [17, 17], [18, 18], [19, 19], [20, 20], [21, 21], [22, 22], [23, 23], [24, 24], [25, 25], [26, 26], [27, 27], [28, 28], [29, 29], [30, 30], [31, 31]]}, {"name" => "Month", "hint" => "Month. Numeric value representing the month of recurrence. Valid values: integers between 1 and 12 inclusive.", "control_type" => "integer", "type" => "integer"}, {"name" => "RecurStartDate", "hint" => "Recurrence Start Date.", "control_type" => "date", "type" => "date"}, {"name" => "Occurrences", "hint" => "Occurrences.", "control_type" => "integer", "type" => "integer"}, {"name" => "RecurEndDate", "hint" => "Recurrence End Date.", "control_type" => "date", "type" => "date"}, {"name" => "LeadDays", "hint" => "Lead Days. Number of days prior to a specified date.", "control_type" => "integer", "type" => "integer"}, {"name" => "AdjDays", "hint" => "Adjustment Days. Indicates the number of days to adjust a value (review a rate or perform interest accrual) after an event occurs (see AdjDaysBasis).", "control_type" => "integer", "type" => "integer"}, {"maxLength" => 80, "name" => "AdjDaysBasis", "hint" => "Adjustment Days Basis. Used in combination with Adjustment Days (AdjDays). It indicates a basis for an adjustment such as: Due Date (DueDt), Statement Date (StmtDt).Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "WeekendOption", "hint" => "Weekend Option. Describes how certain functionality, e.g. Transfers are processed on the Weekend.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "WeekendOptionEnumDesc", "hint" => "WeekendOption Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "type" => "array"}], "object_ref_name" => "TimeFrameType", "ref_uuid" => "1fe45ad8-ec76-45c3-ac22-1ccb2d834ab2", "name" => "TimeFrame", "label" => "TimeFrameType", "type" => "object"}, {"name" => "ExpDt", "hint" => "Expiration Date.", "control_type" => "date", "type" => "date"}, {"name" => "Retention", "hint" => "Retention. Indicates whether the records are to be retained or deleted based on Service Provider criteria.", "control_type" => "checkbox", "type" => "boolean"}, {"name" => "RevertToPartyAddr", "hint" => "Revert to Party Address. Indicates for account alternate addresses if the address must be reverted to the Party name and address.", "control_type" => "checkbox", "type" => "boolean"}, {"name" => "MoveInDt", "hint" => "Move In Date.", "control_type" => "date", "type" => "date"}, {"maxLength" => 80, "name" => "ContactMethod", "hint" => "Contact Method.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "UpDt", "hint" => "Update Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 300, "name" => "Comment", "hint" => "Comment. A comment entered in history.Value should not be more than 300 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 20, "name" => "CensusTract", "hint" => "Census Track. Contains the census tract number assigned to the address.Value should not be more than 20 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 20, "name" => "CensusBlock", "hint" => "Census Block. Contains the census block group designation for the block where the address is within a census tract.Value should not be more than 20 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "ForeignFlag", "hint" => "Foreign Flag. Indicator that tells if an item (an address for example) is foreign or not.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 80, "name" => "HandlingCode", "hint" => "Handling Code .Indicates special handling of notification and statement forms.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "HandlingCodeEnumDesc", "hint" => "Handling Code Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"object_ref_name" => "HandlingCodeOptionType", "ref_uuid" => "b3d9f98a-e9b2-4c68-a382-9d1000e17e36", "name" => "HandlingCodeOption", "label" => "HandlingCodeOptionType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["StatementsNoticesChecks", "StatementsNoticesChecks"], ["Statements", "Statements"], ["StatementsNotices", "StatementsNotices"], ["StatementsChecks", "StatementsChecks"], ["Notices", "Notices"], ["NoticesChecks", "NoticesChecks"], ["Checks", "Checks"], ["DoNotPrint", "DoNotPrint"], ["UsePortfolio", "UsePortfolio"], ["UseDefault", "UseDefault"]]}, {"maxLength" => 80, "name" => "HandlingCodeOptionEnumDesc", "hint" => "Handling Code Option Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "MSACode", "hint" => "MSA Code. MSAs are defined by the U.S. Office of Management and Budget (OMB), and used by the U.S. Census Bureau and other federal government agencies for statistical purposes", "control_type" => "integer", "type" => "integer"}, {"maxLength" => 80, "name" => "MSACodeEnumDesc", "hint" => "MSA Code Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "MaintDt", "hint" => "Maintenance Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "MaintBy", "hint" => "Maintained By.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "MaintByEnumDesc", "hint" => "Maintained By Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "AddrInUseInd", "hint" => "Address In Use.", "control_type" => "checkbox", "type" => "boolean"}, {"name" => "PhoneNum", "hint" => "Phone Number.", "of" => "object", "properties" => [{"maxLength" => 80, "name" => "PhoneType", "optional" => false, "hint" => "Phone Type.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PhoneTypeEnumDesc", "hint" => "Phone Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PhoneIdent", "hint" => "Phone Identifier. Use when you have more than one occurrence of a phone type  (for example 5 Mobile phones). This element serializes the phones.", "control_type" => "integer", "type" => "integer"}, {"name" => "Phone", "hint" => "Phone.", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "PhoneExchange", "hint" => "Phone Exchange.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PreferredPhone", "hint" => "Preferred Phone.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 10, "name" => "Priority", "hint" => "Priority Code.Value should not be more than 10 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "DoNotContactInd", "hint" => "Do Not Contact Indicator.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 30, "name" => "PhoneDesc", "hint" => "Phone Description.Value should not be more than 30 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"maxLength" => 80, "name" => "CountryCodeSource", "hint" => "Country Code Source. Used with CountryCodeValue to indicate the Country Code Source table.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValue", "optional" => false, "hint" => "Country Code Value. Indicates the Country Code Value within the CountryCodeSource table specified.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValueEnumDesc", "hint" => "Country Code Value Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "CountryCodeType", "ref_uuid" => "ee56204d-5b19-4df8-bb91-5caef4d17f78", "name" => "CountryCode", "label" => "CountryCodeType", "type" => "object"}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "UpDt", "hint" => "Update Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}], "type" => "array"}, {"name" => "InvalidAddrInd", "hint" => "Indicates that the address has been identified as a not viable method to contact the customer. ", "control_type" => "checkbox", "type" => "boolean"}, {"name" => "IncAddrFormat", "control_type" => "checkbox", "type" => "boolean"}], "name" => "PostAddr", "type" => "object"}, {"properties" => [{"maxLength" => 36, "name" => "EmailIdent", "hint" => "Email Identification.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "EmailType", "hint" => "Email Type. Indicates the type of email address.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "EmailTypeEnumDesc", "hint" => "Email Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 254, "name" => "EmailAddr", "hint" => "Email Address.Value should not be more than 254 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PreferredEmail", "hint" => "Preferred Email.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 10, "name" => "Priority", "hint" => "Priority Code.Value should not be more than 10 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "EmailType", "ref_uuid" => "4f4bad2d-0c9f-4dc8-a8fa-0fef2b3ad616", "name" => "Email", "label" => "EmailType", "type" => "object"}, {"properties" => [{"name" => "WebAddrIdent", "hint" => "Web Address Identifier. Use when you have more than one occurrence of a web address type. This element serializes the web addresses.", "control_type" => "integer", "type" => "integer"}, {"maxLength" => 80, "name" => "WebAddrType", "hint" => "Web Address Type.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "WebAddrTypeEnumDesc", "hint" => "Web Address Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 1024, "name" => "WebAddrLink", "hint" => "Web Address Link.Value should not be more than 1024 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "PreferredWebAddr", "hint" => "Preferred Web Address.", "control_type" => "checkbox", "type" => "boolean"}], "object_ref_name" => "WebAddrType", "ref_uuid" => "4d1bee84-2ab5-48d1-8b00-cd857be1ff99", "name" => "WebAddr", "label" => "WebAddrType", "type" => "object"}, {"maxLength" => 36, "name" => "ContactIdent", "hint" => "Contact Identifier. Refers to a customer number if the contact is a customer in the customer file.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 40, "name" => "ContactName", "hint" => "Contact. Contact Name.Value should not be more than 40 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 32, "name" => "ContactTitle", "hint" => "Contact Job Title.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "DoNotSolicitInd", "hint" => "Do Not Solicit Indicator. Use to determine whether contact information can be used for solicitation.", "control_type" => "checkbox", "type" => "boolean"}], "type" => "array"}, {"object_ref_name" => "TaxIdentTypeType", "ref_uuid" => "245e0119-3138-448c-935f-e492978473a6", "name" => "TaxIdentType", "label" => "TaxIdentTypeType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["None", "None"], ["SSN", "SSN"], ["EIN", "EIN"], ["Foreign", "Foreign"], ["ITIN", "ITIN"], ["ATIN", "ATIN"], ["Other", "Other"]]}, {"maxLength" => 80, "name" => "TaxIdentTypeEnumDesc", "hint" => "Tax Identification Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 12, "name" => "TaxIdent", "hint" => "Tax Identification.Value should not be more than 12 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "TaxIdentApplyDt", "hint" => "Tax Identifier Application Date.", "control_type" => "date", "type" => "date"}, {"name" => "IssuedIdent", "hint" => "Issued Identification. Used to include issued identifications. If the identification is government issued, the GovIssuedIdent aggregate must be included.", "of" => "object", "properties" => [{"maxLength" => 80, "name" => "IssuedIdentType", "optional" => false, "hint" => "Issued Identification Type. Valid values: DrvrsLicNb, BirthCertificate, HealthCard, Military, AlnRegnNb, IdntyCardNb, VoterRegistration, PsptNb, MplyrIdNb, TaxIdNb,  SclSctyNb, NRAPersonal, NRABusiness, Other.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "IssuedIdentTypeEnumDesc", "hint" => "Issued Identification Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 36, "name" => "IssuedIdentId", "hint" => "Issued Identification Id.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 50, "name" => "IssuedIdentValue", "hint" => "Issued Identification Value. Identification value associated with the identification type.Value should not be more than 50 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 32, "name" => "Issuer", "hint" => "Issuer.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "IssuerEnumDesc", "hint" => "Issuer Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "IssuerLocation", "hint" => "Issuer Location.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "IssuerLocationEnumDesc", "hint" => "Issuer Location Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "IssueDt", "hint" => "Issue Date.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}, {"name" => "ExpDt", "hint" => "Expiration Date.", "control_type" => "date", "type" => "date"}, {"name" => "IdentVerifyDt", "hint" => "Identification Verification Date.", "control_type" => "date", "type" => "date"}, {"name" => "NextIdentVerifyDt", "hint" => "Next Identification Verification Date.", "control_type" => "date", "type" => "date"}, {"maxLength" => 255, "name" => "VerificationDetailText", "hint" => "Verification Detail Text.Value should not be more than 255 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"properties" => [{"maxLength" => 80, "name" => "CountryCodeSource", "hint" => "Country Code Source. Used with CountryCodeValue to indicate the Country Code Source table.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValue", "optional" => false, "hint" => "Country Code Value. Indicates the Country Code Value within the CountryCodeSource table specified.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "CountryCodeValueEnumDesc", "hint" => "Country Code Value Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "CountryCodeType", "ref_uuid" => "027add40-2d2e-45de-af66-d72f061c0a13", "name" => "CountryCode", "optional" => false, "label" => "CountryCodeType", "type" => "object"}, {"maxLength" => 80, "name" => "StateProv", "hint" => "State/Province. ISO 3166-2:US codes.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "StateProvEnumDesc", "hint" => "State Province Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "GovIssuedIdentType", "ref_uuid" => "b5996092-167b-4705-9e05-e37cab98fac7", "name" => "GovIssuedIdent", "label" => "GovIssuedIdentType", "type" => "object"}], "type" => "array"}, {"name" => "OEDCode", "hint" => "Officer, Employee, DIrector Code. Indicates if the party is an employee of the Bank."}, {"maxLength" => 80, "name" => "OEDCodeEnumDesc", "hint" => "Officer Employee Director Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "EmployeeInd", "hint" => "Employee Indicator. Indicates that the account holder is employee of the FI.", "control_type" => "checkbox", "type" => "boolean"}, {"name" => "RestrictedInd", "hint" => "Restricted Indicator. Indicates whether the account information is restricted for view by the requester.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 80, "name" => "RestrictedDesc", "hint" => "Restricted Description. Description of the reason for the account to be restricted.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "SecretData", "hint" => "Secret Data.", "of" => "object", "properties" => [{"maxLength" => 80, "name" => "SecretIdent", "hint" => "Secret Identifier.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "SecretIdentEnumDesc", "hint" => "Secret Identifier Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "SecretValue", "hint" => "Secret Value.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}], "type" => "array"}, {"maxLength" => 32, "name" => "OriginatingBranch", "hint" => "Originating Branch. Branch first originated the relationship with party or created the account.Value should not be more than 32 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "OriginatingBranchEnumDesc", "hint" => "Originating Branch Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "ServiceLevel", "hint" => "Service Level. Indicates the level of service or the type of pricing that the customer should receiveValue should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "ServiceLevelEnumDesc", "hint" => "Service Level Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "MarketSegment", "hint" => "Party Market Segment.  Value that the institution can can use to enter marketing information for this customer.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "MarketSegmentEnumDesc", "hint" => "Party Market Segment Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 255, "name" => "TelebancPswd", "hint" => "Telebanc Password. The Electronic Banking Password is the number used for personal identification when accessing information in Connect3.Value should not be more than 255 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 10, "name" => "SocioEconomicCode", "hint" => "Socio Economic Code.Value should not be more than 10 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 80, "name" => "SocioEconomicCodeEnumDesc", "hint" => "Socio Economic Code Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"properties" => [{"object_ref_name" => "NameTypeType", "ref_uuid" => "58672f77-b571-44ad-86b4-8771771dc20d", "name" => "NameType", "optional" => false, "label" => "NameTypeType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["Primary", "Primary"], ["Secondary", "Secondary"], ["Legal", "Legal"]]}, {"maxLength" => 80, "name" => "NameTypeEnumDesc", "hint" => "Name Type Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 36, "name" => "NameIdent", "hint" => "Name Identifier.Value should not be more than 36 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 130, "name" => "Name", "hint" => "Name.Value should not be more than 130 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 96, "name" => "PreferredName", "hint" => "Preferred Name or Nickname.  For an organization this is the 'doing business as' name.Value should not be more than 96 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 96, "name" => "LegalName", "hint" => "Legal Name. Legal Name of the Organization.Value should not be more than 96 characters. ", "control_type" => "text", "type" => "string"}, {"object_ref_name" => "NameFormatType", "ref_uuid" => "33e8674d-30ed-41a5-9902-b4fa2f157788", "name" => "NameFormat", "label" => "NameFormatType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["None", "None"], ["NonPersonal", "NonPersonal"], ["FirstLastSuffix", "FirstLastSuffix"], ["FirstMiddleInitialLastSuffix", "FirstMiddleInitialLastSuffix"], ["FirstMiddleLastSuffix", "FirstMiddleLastSuffix"], ["PrintedMailingSeasonal", "PrintedMailingSeasonal"], ["PrintedMailingSeasonalTax", "PrintedMailingSeasonalTax"], ["PrintedSeasonalOnly", "PrintedSeasonalOnly"], ["PrintedAddressOnly", "PrintedAddressOnly"]]}, {"maxLength" => 80, "name" => "NameFormatEnumDesc", "hint" => "Name Format Enumeration Description.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "NameInUseInd", "hint" => "Name In Use Indicator.", "control_type" => "checkbox", "type" => "boolean"}], "object_ref_name" => "OrgNameType", "ref_uuid" => "45eefccb-c971-4017-ac54-d67182a9f19a", "name" => "OrgName", "label" => "OrgNameType", "type" => "object"}, {"maxLength" => 19, "name" => "RecipientGIIN", "hint" => "RecipientGlobal Intermediary Identification Number. IRS assigns to a Participating Foreign Financial Institution (PFFI) or Registered Deemed Compliant FFI after a financial institution’s FATCA registration is submitted and approved.Value should not be more than 19 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "LegalForm", "hint" => "Legal Form. PublicLimitedCompany, PrivateLimitedCompany, SoleTraders, Partnership, LimitedLiabilityPartnership, Club, Society."}, {"name" => "BeneficialOwnerReqInd", "hint" => "Beneficial Owner Required Indicator.", "control_type" => "checkbox", "type" => "boolean"}, {"name" => "OrgEstablishDt", "hint" => "Organization Establish Date.", "control_type" => "date", "type" => "date"}], "object_ref_name" => "OrgPartyListInfoType", "ref_uuid" => "4667a9a5-3ea0-41f1-abd7-42f0015555b3", "label" => "OrgPartyListInfoType", "hint" => "Party Information.", "name" => "OrgPartyListInfo", "type" => "object"}, {"properties" => [{"object_ref_name" => "PartyStatusCodeType", "ref_uuid" => "10fd4ec0-1a8e-4426-abc8-5e94ef01a28b", "name" => "PartyStatusCode", "optional" => false, "label" => "PartyStatusCodeType", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["Valid", "Valid"], ["Deleted", "Deleted"]]}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "EffDt", "hint" => "Effective Date. The date that an associated action takes effect.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}], "object_ref_name" => "PartyStatusType", "ref_uuid" => "54087663-1132-41b9-8a48-22712bf11d28", "name" => "PartyStatus", "optional" => false, "label" => "PartyStatusType", "type" => "object"}], "type" => "array"}]),
            label: "PartyListInqRsType",
            type: "object",
            name: "PartyListInqRsType"
          }
        ]
      end
    },
    Context: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['CountryCodeSourceType'].map { |x| x.merge(name: 'CountryCodeSourceType_TerminalCountryCodeSource_request_body') }.map { |x| x.merge({"location" => "request_body"}).merge({ "name" =>  x[:name].to_s+'_request_body' })}.concat(object_definitions['CountryCodeSourceType'].map { |x| x.merge(name: 'CountryCodeSourceType_AcquirerCountryCodeSource_request_body') }.map { |x| x.merge({"location" => "request_body"}).merge({ "name" =>  x[:name].to_s+'_request_body' })}).concat(object_definitions['TellerTrnDataType'].map { |x| x.merge(name: 'TellerTrnDataType_TellerTrnData_request_body') }.map { |x| x.merge({"location" => "request_body"}).merge({ "name" =>  x[:name].to_s+'_request_body' })}).concat([{"maxLength" => 40, "description" => "Name of the client application that is used to send the service request, such as Architect, Commercial Center and others.", "name" => "ClientAppName_request_body", "control_type" => "text", "type" => "string", "original_name" => "ClientAppName", "label" => "ClientAppName", "location" => "request_body"}, {"maxLength" => 80, "description" => "Name of the channel used by the client application.\n  - 'Online'\n  - 'Phone' \n  - 'Branch'\n  - 'EFT'\n  - 'Teller'\n  ", "name" => "Channel_request_body", "control_type" => "text", "type" => "string", "original_name" => "Channel", "label" => "Channel", "location" => "request_body"}, {"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "description" => "Client date and time as reported by the client application that is making the service request.", "name" => "ClientDateTime_request_body", "control_type" => "text", "type" => "string", "original_name" => "ClientDateTime", "label" => "ClientDateTime", "location" => "request_body"}, {"description" => "Indicates whether previous exception is being overridden by the sender.", "name" => "isOverridden_request_body", "control_type" => "checkbox", "type" => "boolean", "toggle_hint" => "Select value", "toggle_field" => {"control_type" => "text", "label" => "isOverridden", "toggle_hint" => "Enter manual value", "toggle_to_secondary_hint" => "Enter manual value", "toggle_to_primary_hint" => "Select value", "type" => "string", "name" => "isOverridden_request_body", "original_name" => "isOverridden", "location" => "request_body"}, "original_name" => "isOverridden", "label" => "isOverridden", "location" => "request_body"}, {"maxLength" => 36, "description" => "Unique identification value of transaction defined by the client.  Also known as Trace Number or Sequence in some systems. When used by a Network defined transaction,  the value of this identifier is typically set to narrow character of 12.", "name" => "TrnIdent_request_body", "control_type" => "text", "type" => "string", "original_name" => "TrnIdent", "label" => "TrnIdent", "location" => "request_body"}, {"maxLength" => 36, "description" => "Client terminal sequence number. type: string", "name" => "ClientTerminalSeqNum_request_body", "original_name" => "ClientTerminalSeqNum", "label" => "ClientTerminalSeqNum", "location" => "request_body"}, {"description" => "The type of organization that the originator represents. This is usually a coded value representing the industry that the organization operates in. It contains the SIC code. For ISO 8583 (DE18) the element is restricted to narrow character of maximum length of 4.  Originator Type codes that apply to financial institutions are:\n  6010 - Financial institution—bank, savings and loan (S and L), or credit union  \n  6011 - Financial institution—ATM \n  6012 - Financial institution—merchandise sale \n  6999 - Financial institution—home banking", "name" => "OriginatorType_request_body", "control_type" => "integer", "type" => "integer", "original_name" => "OriginatorType", "label" => "OriginatorType", "location" => "request_body"}, {"maxLength" => 36, "description" => "Unique code identifying a terminal at the card acceptor location (such as terminal code or terminal number of ATM). See For ISO 8583 (DE41) the element is restricted to a narrow character with maximum length of 8.", "name" => "TerminalIdent_request_body", "control_type" => "text", "type" => "string", "original_name" => "TerminalIdent", "label" => "TerminalIdent", "location" => "request_body"}, {"maxLength" => 64, "description" => "Terminal address line 1.", "name" => "TerminalAddr1_request_body", "control_type" => "text", "type" => "string", "original_name" => "TerminalAddr1", "label" => "TerminalAddr1", "location" => "request_body"}, {"maxLength" => 64, "description" => "Terminal address line 2.", "name" => "TerminalAddr2_request_body", "control_type" => "text", "type" => "string", "original_name" => "TerminalAddr2", "label" => "TerminalAddr2", "location" => "request_body"}, {"maxLength" => 64, "description" => "Terminal address line 3.", "name" => "TerminalAddr3_request_body", "control_type" => "text", "type" => "string", "original_name" => "TerminalAddr3", "label" => "TerminalAddr3", "location" => "request_body"}, {"maxLength" => 64, "description" => "Terminal address line 4.", "name" => "TerminalAddr4_request_body", "control_type" => "text", "type" => "string", "original_name" => "TerminalAddr4", "label" => "TerminalAddr4", "location" => "request_body"}, {"maxLength" => 40, "description" => "Terminal city name.", "name" => "TerminalCity_request_body", "control_type" => "text", "type" => "string", "original_name" => "TerminalCity", "label" => "TerminalCity", "location" => "request_body"}, {"maxLength" => 40, "description" => "Terminal county name.", "name" => "TerminalCounty_request_body", "control_type" => "text", "type" => "string", "original_name" => "TerminalCounty", "label" => "TerminalCounty", "location" => "request_body"}, {"maxLength" => 32, "description" => "State province value as per ISO 3166-2:US codes where the terminal is located.", "name" => "TerminalStateProv_request_body", "control_type" => "text", "type" => "string", "original_name" => "TerminalStateProv", "label" => "TerminalStateProv", "location" => "request_body"}, {"maxLength" => 11, "description" => "Postal Code where the terminal is located. ", "name" => "TerminalPostalCode_request_body", "control_type" => "text", "type" => "string", "original_name" => "TerminalPostalCode", "label" => "TerminalPostalCode", "location" => "request_body"}, {"maxLength" => 80, "description" => "Country code value as per the ISO source code set in the TerminalCountryCodeSource field.", "name" => "TerminalCountryCodeValue_request_body", "control_type" => "text", "type" => "string", "original_name" => "TerminalCountryCodeValue", "label" => "TerminalCountryCodeValue", "location" => "request_body"}, {"maxLength" => 80, "description" => "Type of a phone. Valid values are: - 'EvePhone' - 'DayPhone' - 'EveFax' - 'DayFax' - 'Home' - 'Work' - 'Mobile' - 'Fax' - 'Pager' - 'Modem' - 'Other'", "name" => "PhoneType_request_body", "control_type" => "text", "type" => "string", "original_name" => "PhoneType", "label" => "PhoneType", "location" => "request_body"}, {"description" => "Phone number.", "name" => "PhoneNum_request_body", "control_type" => "text", "type" => "string", "original_name" => "PhoneNum", "label" => "PhoneNum", "location" => "request_body"}, {"maxLength" => 80, "description" => "Phone exchange.", "name" => "PhoneExchange_request_body", "control_type" => "text", "type" => "string", "original_name" => "PhoneExchange", "label" => "PhoneExchange", "location" => "request_body"}, {"maxLength" => 40, "description" => "Name of the owner or operator of the terminal.  For ISO 8583 (DE43) the element is restricted to C-15.", "name" => "TerminalOwnerName_request_body", "control_type" => "text", "type" => "string", "original_name" => "TerminalOwnerName", "label" => "TerminalOwnerName", "location" => "request_body"}, {"maxLength" => 36, "description" => "Number assigned by the transaction originator to assist in identifying a transaction uniquely. The trace number remains unchanged for all messages throughout the life of a transaction. This number is not a terminal receipt number. The originating processor increments the trace number by one for each transaction sent to the switch. For ISO 8583 (DE11) the element is restricted to NC-6", "name" => "SystTraceAuditNum_request_body", "control_type" => "text", "type" => "string", "original_name" => "SystTraceAuditNum", "label" => "SystTraceAuditNum", "location" => "request_body"}, {"maxLength" => 80, "description" => "Identifies the interchange network for the transaction. The transaction is applied to the specified network settlement counts and balances. For ISO 8583 (DE62) the element is restricted to NC-6", "name" => "NetworkIdent_request_body", "control_type" => "text", "type" => "string", "original_name" => "NetworkIdent", "label" => "NetworkIdent", "location" => "request_body"}, {"maxLength" => 36, "description" => "Document reference supplied by the system retaining the original source document and used to assist in locating that document. The acquirer of a transaction assigns this number. The issuer processor must retain it in the event that a chargeback is submitted for the transaction. For ISO 8583 (DE37) the element is restricted to C-12.", "name" => "NetworkRefIdent_request_body", "control_type" => "text", "type" => "string", "original_name" => "NetworkRefIdent", "label" => "NetworkRefIdent", "location" => "request_body"}, {"maxLength" => 36, "description" => "Identifier of the acquirer who processes the financial transaction. It is a mandatory element in all authorization and financial messages and does not change throughout the life of a transaction. EPOC considers the acquirer as the terminal owner for reporting purposes. For ISO 8583 (DE32) the element is restricted to C-12", "name" => "AcquirerIdent_request_body", "control_type" => "text", "type" => "string", "original_name" => "AcquirerIdent", "label" => "AcquirerIdent", "location" => "request_body"}, {"maxLength" => 80, "description" => "Country code value of Acquirer as per the ISO source code set in the AcquirerCountryCodeSource field.", "name" => "AcquirerCountryCodeValue_request_body", "control_type" => "text", "type" => "string", "original_name" => "AcquirerCountryCodeValue", "label" => "AcquirerCountryCodeValue", "location" => "request_body"}, {"maxLength" => 23, "description" => "Unique identification number of a merchant.  For ISO 8583 (DE42) the element is restricted to C-15", "name" => "MerchNum_request_body", "control_type" => "text", "type" => "string", "original_name" => "MerchNum", "label" => "MerchNum", "location" => "request_body"}, {"description" => "Transaction settlement date. Used by ISO 8583 (DE63).", "name" => "SettlementDate_request_body", "control_type" => "date", "type" => "date", "original_name" => "SettlementDate", "label" => "SettlementDate", "location" => "request_body"}, {"maxLength" => 36, "description" => "Identification of the settlement account in which the transaction will be settled.", "name" => "SettlementIdent_request_body", "control_type" => "text", "type" => "string", "original_name" => "SettlementIdent", "label" => "SettlementIdent", "location" => "request_body"}, {"maxLength" => 80, "description" => "Identification of the business application. Valid values are:\n  - 'P2P' - Person-to-Person\n  - 'C2B' - Consumer-to-Business\n  - 'A2A' - Account-to-Account\n  - 'B2C' - Business-to-Consumer\n  - 'B2B' - Business-to-Business\n  - 'G2C' - Government-to-Consumer\n  - 'C2G' - Consumer-to-Government", "name" => "BusinessApplIdent_request_body", "control_type" => "text", "type" => "string", "original_name" => "BusinessApplIdent", "label" => "BusinessApplIdent", "location" => "request_body"}, {"maxLength" => 22, "description" => "Branch identification number.", "name" => "BranchIdent_request_body", "control_type" => "text", "type" => "string", "original_name" => "BranchIdent", "label" => "BranchIdent", "location" => "request_body"}, {"maxLength" => 80, "description" => "Teller identification number.", "name" => "TellerIdent_request_body", "control_type" => "text", "type" => "string", "original_name" => "TellerIdent", "label" => "TellerIdent", "location" => "request_body"}, {"maxLength" => 80, "description" => "Till identification number.", "name" => "TillIdent_request_body", "control_type" => "text", "type" => "string", "original_name" => "TillIdent", "label" => "TillIdent", "location" => "request_body"}, {"description" => "Transaction posting code. ", "name" => "AMPMCode_request_body", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["AM", "AM"], ["PM", "PM"]], "toggle_hint" => "Select value", "toggle_field" => {"control_type" => "text", "label" => "AMPMCode", "toggle_hint" => "Enter manual value", "toggle_to_secondary_hint" => "Enter manual value", "toggle_to_primary_hint" => "Select value", "type" => "string", "name" => "AMPMCode_request_body", "original_name" => "AMPMCode", "location" => "request_body"}, "original_name" => "AMPMCode", "label" => "AMPMCode", "location" => "request_body"}, {"description" => "Type of re-entry.", "name" => "ReentryType_request_body", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["Manual", "Manual"], ["Auto", "Auto"]], "toggle_hint" => "Select value", "toggle_field" => {"control_type" => "text", "label" => "ReentryType", "toggle_hint" => "Enter manual value", "toggle_to_secondary_hint" => "Enter manual value", "toggle_to_primary_hint" => "Select value", "type" => "string", "name" => "ReentryType_request_body", "original_name" => "ReentryType", "location" => "request_body"}, "original_name" => "ReentryType", "label" => "ReentryType", "location" => "request_body"}, {"maxLength" => 80, "description" => "Transaction group identifier.", "name" => "GroupIdent_request_body", "control_type" => "text", "type" => "string", "original_name" => "GroupIdent", "label" => "GroupIdent", "location" => "request_body"}, {"additionalProperties" => true, "description" => "Contains additional information required to successfully process the transaction. Required By Cleartouch", "name" => "AdditionalSettings_request_body", "type" => "object", "original_name" => "AdditionalSettings", "label" => "AdditionalSettings", "location" => "request_body"}]),
            name: "Context",
            type: "object",
            original_name: "Context",
            label: "Context"
          }
        ]
      end
    },
    OvrdElementType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [
              {
                name: "Path_request_body",
                hint: "Path of the element (in XPath absolute notation format) where the error occurred.  If the error occurred at the top-level element, then name of the element is returned in the response. ",
                control_type: "text",
                type: "string",
                original_name: "Path",
                label: "Path",
                location: "request_body"
              },
              {
                maxLength: 256,
                name: "ServerPath_request_body",
                hint: "Server Path is the Service Provider’s identification of the field in their schema, such as an XPath, field ID, or field name that is associated with the ServerStatusCode. If this element is set, it must be returned in the ServerPath element of the OvrdExceptionData aggregate if the exception is being overridden.Value should not be more than 256 characters. ",
                control_type: "text",
                type: "string",
                original_name: "ServerPath",
                label: "ServerPath",
                location: "request_body"
              },
              {
                maxLength: 256,
                name: "Value_request_body",
                hint: "Human readable information of the EFX data value of the element to  be overridden. This value should not be provided for the fields that  cannot be represented as a string, for example, binary data.Value should not be more than 256 characters. ",
                control_type: "text",
                type: "string",
                original_name: "Value",
                label: "Value",
                location: "request_body"
              },
              {
                type: "object",
                location: "request_body"
              }
            ],
            label: "OvrdElement",
            hint: "Information about the subject element.",
            name: "OvrdElementType",
            type: "object",
            original_name: "OvrdElement"
          }
        ]
      end
    },
    PartyKeysType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['SvcIdentType'].map { |x| x.merge(name: 'SvcIdent') }.concat(object_definitions['PartyIdentTypeType'].map { |x| x.merge(name: 'PartyIdentType') }).concat([{"maxLength" => 150, "name" => "PartyId", "original_name" => "PartyId", "hint" => "Party Identifier. Used to uniquely identify a Party record.Value should not be more than 150 characters. ", "control_type" => "text", "type" => "string", "location" => "request_body"}, {"maxLength" => 60, "name" => "PartyIdent", "original_name" => "PartyIdent", "hint" => "Party Identification.Value should not be more than 60 characters. ", "control_type" => "text", "type" => "string", "location" => "request_body"}]),
            name: "PartyKeysType",
            label: "PartyKeysType",
            type: "object",
            original_name: "PartyKeys"
          }
        ]
      end
    },
    AddrFormatTypeType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            name: "AddrFormatTypeType",
            label: "AddrFormatTypeType",
            control_type: "select",
            type: "string",
            extends_schema: true,
            pick_list: [
              ["Label", "Label"],
              ["Parsed", "Parsed"]
            ]
          }
        ]
      end
    },
    AddrTypeType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            name: "AddrTypeType",
            label: "AddrTypeType",
            control_type: "select",
            type: "string",
            extends_schema: true,
            pick_list: [
              ["Primary", "Primary"],
              ["PrimaryPending", "PrimaryPending"],
              ["Secondary", "Secondary"],
              ["Seasonal", "Seasonal"],
              ["Previous", "Previous"],
              ["Physical", "Physical"]
            ]
          }
        ]
      end
    },
    StatusType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['SeverityType'].map { |x| x.merge(name: 'Severity') }.concat([{"name" => "Id", "hint" => "Status identification number.", "control_type" => "text", "type" => "string"}, {"maxLength" => 20, "name" => "StatusCode", "optional" => false, "hint" => "EFX Standard Status code that indicates the result of API response. Value should not be more than 20 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 255, "name" => "StatusDesc", "optional" => false, "hint" => "Brief description about the EFX status code. Value should not be more than 255 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 1024, "name" => "SvcProviderName", "optional" => false, "hint" => "Name of a service provider. Possible values are:\n  -  'Cleartouch'\n  -  'DNA'\n  -  'Precision'\n  -  'Premier'\n  -  'Signature'\n  -  'Finxact'\n  -  'NIA'\n  -  'Director'Value should not be more than 1024 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 20, "name" => "ServerStatusCode", "hint" => "Server status code of the service provider's application.  Value should not be more than 20 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 255, "name" => "ServerStatusDesc", "hint" => "Description of the server status code of the service provider's application.Value should not be more than 255 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "OvrdExceptionInd", "hint" => "Indicates whether the exception can be overridden by resubmitting the request message.", "control_type" => "checkbox", "type" => "boolean"}, {"maxLength" => 80, "name" => "SubjectRole", "hint" => "Authorization level required to override, such as Teller and Supervisor.Value should not be more than 80 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "SubjectElement", "hint" => "Information about the elements that caused the status.", "of" => "object", "properties" => [{"name" => "Path", "hint" => "Path of the element (in XPath absolute notation format) where the error occurred.  If the error occurred at the top-level element, then name of the element is returned in the response. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 256, "name" => "ServerPath", "hint" => "Server Path is the Service Provider’s identification of the field in their schema, such as an XPath, field ID, or field name that is associated with the ServerStatusCode. If this element is set, it must be returned in the ServerPath element of the OvrdExceptionData aggregate if the exception is being overridden.Value should not be more than 256 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 256, "name" => "Value", "hint" => "Human readable information of the EFX data value of the element to  be overridden. This value should not be provided for the fields that  cannot be represented as a string, for example, binary data.Value should not be more than 256 characters. ", "control_type" => "text", "type" => "string"}], "type" => "array"}, {"name" => "ContentHTML", "hint" => "Response status in HTML format. This parameter returns only in some  cases. #(excluding the core specific information), for example,  in Premier, upon failure an HTML page is provided to support the  maintenance of reported failures.", "control_type" => "text", "type" => "string"}, {"name" => "AdditionalStatus", "hint" => "Additional statuses of the response message. ", "of" => "object", "properties" => [{"maxLength" => 20, "name" => "StatusCode", "hint" => "EFX Standard Status code that indicates the result of API response. Value should not be more than 20 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 255, "name" => "StatusDesc", "hint" => "Brief description about the EFX status code.Value should not be more than 255 characters. ", "control_type" => "text", "type" => "string"}, {"object_ref_name" => "SeverityType", "ref_uuid" => "77dbbd65-d686-45e0-a5ff-6a65aafc3eb3", "name" => "Severity", "label" => "SeverityType", "hint" => "Severity type of the EFX status code. ", "control_type" => "select", "type" => "string", "extends_schema" => true, "pick_list" => [["Error", "Error"], ["Warning", "Warning"], ["Info", "Info"]]}, {"maxLength" => 1024, "name" => "SvcProviderName", "hint" => "Name of a service provider. Possible values are:\n  - 'Cleartouch'\n  - 'DNA'\n  - 'Precision'\n  - 'Premier'\n  - 'Signature'\n  - 'Finxact'\n  - 'NIA'\n  - 'Director'Value should not be more than 1024 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 20, "name" => "ServerStatusCode", "hint" => "Server status code of the service provider's application.  Value should not be more than 20 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 255, "name" => "ServerStatusDesc", "hint" => "Description of the server status code of the service provider's application.Value should not be more than 255 characters. ", "control_type" => "text", "type" => "string"}, {"name" => "OvrdExceptionInd", "hint" => "Flag that indicates whether the exception can be overridden by resubmitting the request message.", "control_type" => "checkbox", "type" => "boolean"}, {"name" => "SubjectElement", "hint" => "Information about the elements that caused the status.", "of" => "object", "properties" => [{"name" => "Path", "hint" => "Path of the element (in XPath absolute notation format) where the error occurred.  If the error occurred at the top-level element, then name of the element is returned in the response. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 256, "name" => "ServerPath", "hint" => "Server Path is the Service Provider’s identification of the field in their schema, such as an XPath, field ID, or field name that is associated with the ServerStatusCode. If this element is set, it must be returned in the ServerPath element of the OvrdExceptionData aggregate if the exception is being overridden.Value should not be more than 256 characters. ", "control_type" => "text", "type" => "string"}, {"maxLength" => 256, "name" => "Value", "hint" => "Human readable information of the EFX data value of the element to  be overridden. This value should not be provided for the fields that  cannot be represented as a string, for example, binary data.Value should not be more than 256 characters. ", "control_type" => "text", "type" => "string"}], "type" => "array"}], "type" => "array"}]),
            name: "StatusType",
            optional: false,
            label: "StatusType",
            hint: "Details of the API response messages.            ",
            type: "object"
          }
        ]
      end
    },
    AddrStatusRecType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['AddrKeysType'].map { |x| x.merge(name: 'AddrKeys') }.concat(object_definitions['AddrStatusType'].map { |x| x.merge(name: 'AddrStatus') }),
            name: "AddrStatusRecType",
            label: "AddrStatusRecType",
            type: "object"
          }
        ]
      end
    },
    EmailStatusRecType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['EmailKeysType'].map { |x| x.merge(name: 'EmailKeys') }.concat(object_definitions['EmailStatusType'].map { |x| x.merge(name: 'EmailStatus') }),
            name: "EmailStatusRecType",
            label: "EmailStatusRecType",
            type: "object"
          }
        ]
      end
    },
    PhoneNumStatusRecType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['PhoneNumKeysType'].map { |x| x.merge(name: 'PhoneNumKeys') }.concat(object_definitions['PhoneNumStatusType'].map { |x| x.merge(name: 'PhoneNumStatus') }),
            name: "PhoneNumStatusRecType",
            label: "PhoneNumStatusRecType",
            type: "object"
          }
        ]
      end
    },
    PartyStatusRecType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['SvcIdentType'].map { |x| x.merge(name: 'SvcIdent') }
            .concat(object_definitions['PartyKeysType'].map { |x| x.merge(name: 'PartyKeys') }.map { |x| x.merge({"location" => "request_body"}).merge({ "name" =>  x[:name].to_s+'_request_body' })})
            .concat(object_definitions['PartyStatusType'].map { |x| x.merge(name: 'PartyStatus') }.map { |x| x.merge({"location" => "request_body"}).merge({ "name" =>  x[:name].to_s+'_request_body' })}),
            name: "PartyStatusRecType",
            label: "PartyStatusRecType",
            type: "object",
            original_name: "PartyStatusRecType"
          }
        ]
      end
    },
    PersonNameSelType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [
              {
                maxLength: 40,
                name: "FamilyName_request_body",
                hint: "Family Name.Value should not be more than 40 characters. ",
                control_type: "text",
                type: "string",
                original_name: "FamilyName",
                label: "FamilyName",
                location: "request_body"
              },
              {
                maxLength: 40,
                name: "GivenName_request_body",
                hint: "Given Name. Person's first name.Value should not be more than 40 characters. ",
                control_type: "text",
                type: "string",
                original_name: "GivenName",
                label: "GivenName",
                location: "request_body"
              },
              {
                maxLength: 40,
                name: "MiddleName_request_body",
                hint: "Middle Name. Person's middle name.Value should not be more than 40 characters. ",
                control_type: "text",
                type: "string",
                original_name: "MiddleName",
                label: "MiddleName",
                location: "request_body"
              }
            ],
            name: "PersonNameSelType",
            label: "PersonNameSel",
            type: "object",
            original_name: "PersonNameSel"
          }
        ]
      end
    },
    ClientDefinedSearchType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [
              {
                maxLength: 36,
                name: "DataIdent_request_body",
                optional: false,
                hint: "Data Identification. Identification of the client defined data item.Value should not be more than 36 characters. ",
                control_type: "text",
                type: "string",
                original_name: "DataIdent",
                label: "DataIdent",
                location: "request_body"
              },
              {
                maxLength: 256,
                name: "Value_request_body",
                hint: "Value string representation of the EFX data value of the element in error. This field is intended to provide a human readable visual hint as to the value in error. It should not be provided for fields that cannot be represented as a string (i.e., binary data).Value should not be more than 256 characters. ",
                control_type: "text",
                type: "string",
                original_name: "Value",
                label: "Value",
                location: "request_body"
              }
            ],
            name: "ClientDefinedSearchType",
            label: "ClientDefinedSearch",
            type: "object",
            original_name: "ClientDefinedSearch"
          }
        ]
      end
    },
    RecCtrlOutType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [
              {
                name: "SentRecCount",
                optional: false,
                hint: "Sent record count is the number of records matching the selection  criteria that are included in this message.",
                control_type: "integer",
                type: "integer"
              },
              {
                name: "MatchedRecCount",
                hint: "Matched record count is the total number of records matching the  selection criteria.",
                control_type: "integer",
                type: "integer"
              },
              {
                name: "RemainRecCount",
                hint: "Remain record count is the total number of records matching the  selection criteria that have not been sent yet.",
                control_type: "integer",
                type: "integer"
              },
              {
                maxLength: 250,
                name: "Cursor",
                hint: "Next record pointer included in the response only if additional  records are available. Value should not be more than 250 characters. ",
                control_type: "text",
                type: "string"
              }
            ],
            name: "RecCtrlOutType",
            hint: "Record Control Out",
            type: "object"
          }
        ]
      end
    },
    CountryCodeSourceType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            title: "CountryCodeSourceType",
            description: "Country code value as per the ISO source code. Posible values:
            - 'ISO3166-Numeric'
            - 'ISO3166-Alpha-3'",
            name: "CountryCodeSourceType",
            control_type: "select",
            type: "string",
            extends_schema: true,
            pick_list: [
              ["ISO3166Numeric", "ISO3166Numeric"],
              ["ISO3166Alpha3", "ISO3166Alpha3"],
              ["ISO3166-Numeric", "ISO3166-Numeric"],
              ["ISO3166-Alpha-3", "ISO3166-Alpha-3"]
            ],
            toggle_hint: "Select value",
            toggle_field: {
              control_type: "text",
              label: "AcquirerCountryCodeSource",
              toggle_hint: "Enter manual value",
              toggle_to_secondary_hint: "Enter manual value",
              toggle_to_primary_hint: "Select value",
              type: "string",
              name: "AcquirerCountryCodeSource_request_body",
              original_name: "AcquirerCountryCodeSource",
              location: "request_body"
            },
            original_name: "AcquirerCountryCodeSource",
            label: "CountryCodeSourceType"
          }
        ]
      end
    },
    TellerTrnDataType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            title: "TellerTrnData",
            properties: [
              {
                maxLength: 80,
                description: "Teller identification number.",
                name: "TellerIdent_request_body",
                control_type: "text",
                type: "string",
                original_name: "TellerIdent",
                label: "TellerIdent",
                location: "request_body"
              },
              {
                description: "Contains data elements that identify the conductor of the  transaction at the teller line. ",
                name: "TrnConductorData_request_body",
                of: "object",
                properties: [
                  {
                    maxLength: 80,
                    description: "Identifies the person conducting the transaction.",
                    name: "TrnConductorIdent_request_body",
                    control_type: "text",
                    type: "string",
                    original_name: "TrnConductorIdent",
                    label: "TrnConductorIdent",
                    location: "request_body"
                  },
                  {
                    maxLength: 80,
                    description: "No conductor reason is used when a conductor cannot be identified. Valid values are:
                    - 'ArmoredCarSvc '
                    - 'MailDeposit' 
                    - 'NightDeposit' 
                    - 'ATM' 
                    - 'AggregatedTransaction' 
                    - 'CourierSvc' ",
                    name: "NoConductorReason_request_body",
                    control_type: "text",
                    type: "string",
                    original_name: "NoConductorReason",
                    label: "NoConductorReason",
                    location: "request_body"
                  }
                ],
                type: "array",
                original_name: "TrnConductorData",
                label: "TrnConductorData",
                location: "request_body"
              }
            ],
            description: "Teller Transaction Data.",
            name: "TellerTrnDataType",
            type: "object",
            original_name: "TellerTrnData",
            label: "TellerTrnData"
          }
        ]
      end
    },
    SvcIdentType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [
              {
                maxLength: 1024,
                name: "SvcProviderName",
                hint: "Service Provider Name is a globally unique identifier for a service provider.Value should not be more than 1024 characters. ",
                control_type: "text",
                type: "string"
              },
              {
                maxLength: 36,
                name: "SvcNbr",
                hint: "Service Number.Value should not be more than 36 characters. ",
                control_type: "text",
                type: "string"
              },
              {
                maxLength: 32,
                name: "SvcName",
                hint: "Service Name.Value should not be more than 32 characters. ",
                control_type: "text",
                type: "string"
              }
            ],
            name: "SvcIdentType",
            label: "SvcIdentType",
            type: "object"
          }
        ]
      end
    },
    PartyIdentTypeType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            name: "PartyIdentTypeType",
            label: "PartyIdentTypeType",
            control_type: "select",
            type: "string",
            extends_schema: true,
            pick_list: [
              ["TaxIdent", "TaxIdent"],
              ["IBId", "IBId"],
              ["Name", "Name"],
              ["MemberNum", "MemberNum"],
              ["OrgNum", "OrgNum"],
              ["PersonNum", "PersonNum"]
            ]
          }
        ]
      end
    },
    SeverityType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            name: "SeverityType",
            optional: false,
            label: "SeverityType",
            hint: "Severity type of the EFX status code. ",
            control_type: "select",
            type: "string",
            extends_schema: true,
            pick_list: [
              ["Error", "Error"],
              ["Warning", "Warning"],
              ["Info", "Info"]
            ]
          }
        ]
      end
    },
    AddrStatusType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [
              {
                maxLength: 80,
                name: "AddrStatusCode",
                optional: false,
                hint: "Address Status Code.Value should not be more than 80 characters. ",
                control_type: "text",
                type: "string"
              },
              {
                pattern: "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\.[0-9]{3})?((-|\+)[0-9]{2}:[0-9]{2})?)?)?",
                name: "EffDt",
                hint: "Effective Date. The date that an associated action takes effect.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\.[0-9]{3})?((-|\+)[0-9]{2}:[0-9]{2})?)?)?. ",
                control_type: "text",
                type: "string"
              }
            ],
            name: "AddrStatusType",
            label: "AddrStatusType",
            type: "object"
          }
        ]
      end
    },
    EmailStatusType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [
              {
                maxLength: 80,
                name: "EmailStatusCode",
                optional: false,
                hint: "Email Status Code.Value should not be more than 80 characters. ",
                control_type: "text",
                type: "string"
              },
              {
                pattern: "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\.[0-9]{3})?((-|\+)[0-9]{2}:[0-9]{2})?)?)?",
                name: "EffDt",
                hint: "Effective Date. The date that an associated action takes effect.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\.[0-9]{3})?((-|\+)[0-9]{2}:[0-9]{2})?)?)?. ",
                control_type: "text",
                type: "string"
              }
            ],
            name: "EmailStatusType",
            optional: false,
            label: "EmailStatusType",
            type: "object"
          }
        ]
      end
    },
    PhoneNumStatusType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [
              {
                maxLength: 80,
                name: "PhoneNumStatusCode",
                optional: false,
                hint: "Phone Number Status Code.Value should not be more than 80 characters. ",
                control_type: "text",
                type: "string"
              },
              {
                pattern: "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\.[0-9]{3})?((-|\+)[0-9]{2}:[0-9]{2})?)?)?",
                name: "EffDt",
                hint: "Effective Date. The date that an associated action takes effect.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\.[0-9]{3})?((-|\+)[0-9]{2}:[0-9]{2})?)?)?. ",
                control_type: "text",
                type: "string"
              }
            ],
            name: "PhoneNumStatusType",
            label: "PhoneStatusType",
            type: "object"
          }
        ]
      end
    },
    PartyStatusType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['PartyStatusCodeType'].map { |x| x.merge(name: 'PartyStatusCode') }.concat([{"pattern" => "[0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?", "name" => "EffDt", "hint" => "Effective Date. The date that an associated action takes effect.Value should follow this pattern [0-9]{4}-[0-9]{2}-[0-9]{2}(T[0-9]{2}:[0-9]{2}(:[0-9]{2}(\\.[0-9]{3})?((-|\\+)[0-9]{2}:[0-9]{2})?)?)?. ", "control_type" => "text", "type" => "string"}]),
            name: "PartyStatusType",
            optional: false,
            label: "PartyStatusType",
            type: "object"
          }
        ]
      end
    },
    PartyStatusCodeType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            name: "PartyStatusCodeType",
            optional: false,
            label: "PartyStatusCodeType",
            control_type: "select",
            type: "string",
            extends_schema: true,
            pick_list: [
              ["Valid", "Valid"],
              ["Deleted", "Deleted"]
            ]
          }
        ]
      end
    },
    XferInfoContainerType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['XferInfoType'].map { |x| x.merge(name: 'XferInfo', label: 'XferInfo', original_name: 'XferInfo') },
            name: "XferInfoContainerType",
            label: "XferInfoContainerType",
            type: "object",
            original_name: "XferInfoContainer"
          }
        ]
      end
    },
    XferInfoType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties:
            [{"name" => "OvrdAutoAckInd", "original_name" => "OvrdAutoAckInd", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}]
            .concat(object_definitions['AcctTransferRefType'].map { |x| x.merge(name: 'FromAcctRef', label: 'FromAcctRef', original_name: 'FromAcctRef') })
            .concat(object_definitions['AcctTransferRefType'].map { |x| x.merge(name: 'ToAcctRef', label: 'ToAcctRef', original_name: 'ToAcctRef') })
            .concat(object_definitions['CurAmtType'].map { |x| x.merge(name: 'CurAmt', label: 'CurAmt') })
            .concat(object_definitions['RecurModelType'].map { |x| x.merge(name: 'RecurModel') })
            .concat(object_definitions['RelationshipMgrType'].map { |x| x.merge(name: 'RelationshipMgr', label: 'RelationshipMgr') })
            .concat([{"name" => "ReportGroupCode", "original_name" => "ReportGroupCode", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "ExpediteInd", "original_name" => "ExpediteInd", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
            .concat(object_definitions['ExtendedXferDataType'].map { |x| x.merge(name: 'ExtendedXferData', label: 'ExtendedXferData') })
            .concat([{"name" => "XferFromDesc", "original_name" => "XferFromDesc", "type" => "array", "of" => "string", "location" => "request_body"}])
            .concat([{"name" => "XferToDesc", "original_name" => "XferToDesc", "type" => "array", "of" => "string", "location" => "request_body"}])
            .concat(object_definitions['RefDataType'].map { |x| x.merge(name: 'RefData', label: 'RefData') }),
            name: "XferInfoType",
            label: "XferInfoType",
            type: "object",
            original_name: "XferInfo"
          }
        ]
      end
    },
    AcctTransferRefType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: object_definitions['AcctTransferKeysType'].map { |x| x.merge(name: 'AcctKeys', label: 'AcctKeys', original_name: 'AcctKeys') },
            name: "AcctTransferRefType",
            label: "AcctTransferRefType",
            type: "object",
            original_name: "AcctTransferRef"
          }
        ]
      end
    },
    AcctTransferKeysType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [{"name" => "AcctId", "original_name" => "AcctId", "control_type" => "text", "type" => "string", "location" => "request_body", "optional" => false}]
            .concat([{"name" => "AcctType", "original_name" => "AcctType", "control_type" => "text", "type" => "string", "location" => "request_body", "optional" => false, "hint" => "Usually one of the following values: DDA, SDA, CDA, EXT, LOAN, SDB or GLA"}])
            .concat(object_definitions['AcctIdentType'].map { |x| x.merge(name: 'AcctIdent', label: 'AcctIdent') })
            .concat(object_definitions['AcctIdentType'].map { |x| x.merge(name: 'AcctIdent', label: 'AcctIdent') })
            .concat([{"name" => "FIIdent", "original_name" => "FIIdent", "control_type" => "text", "type" => "string", "location" => "request_body", "list_mode" => "static"}])
            .concat([{"name" => "FIIdentType", "original_name" => "FIIdentType", "control_type" => "select", "options" => [ ["RoutingNum", "RoutingNum"] ], "location" => "request_body"}]),
            name: "AcctTransferKeysType",
            label: "AcctTransferKeysType",
            type: "object",
            original_name: "AcctTransferKeys"
          }
        ]
      end
    },
    AcctIdentType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: [{"name" => "AcctIdentType", "original_name" => "AcctIdentType", "control_type" => "select", "options" => [ ["AcctTypeCode", "AcctTypeCode"] ], "location" => "request_body"}]
            .concat([{"name" => "AcctIdentValue", "original_name" => "AcctIdentValue", "control_type" => "select", "options" => [ ["DDA", "DDA"], ["SDA", "SDA"], ["LOAN", "LOAN"], ["Vendor", "Vendor"], ["Check", "Check"], ["None", "None"] ], "location" => "request_body"}]),
            name: "AcctIdentType",
            label: "AcctIdentType",
            type: "array",
            of: "object",
            original_name: "AcctIdent"
          }
        ]
      end
    },
    CurAmtType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "Amt", "original_name" => "Amt", "type" => "number", "control_type" => "number", "convert_input" => "float_conversion", "location" => "request_body", "optional" => false}]
            .concat(object_definitions['CurCodeType'].map { |x| x.merge(name: 'CurCode', label: 'CurCode') })
            .concat([{"name" => "StmtRunningBalType", "original_name" => "StmtRunningBalType", "control_type" => "text", "type" => "string", "location" => "request_body"}]),
            name: "CurAmtType",
            label: "CurAmtType",
            type: "object",
            original_name: "CurAmt"
          }
        ]
      end
    },
    CurCodeType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "CurCodeType", "original_name" => "CurCodeType", "control_type" => "select", "options" => [ ["ISO4217-Alpha", "ISO4217-Alpha"] ], "location" => "request_body"}]
            .concat([{"name" => "CurCodeValue", "original_name" => "CurCodeValue", "control_type" => "text", "type" => "string", "location" => "request_body"}]),
            name: "CurCodeType",
            label: "CurCodeType",
            type: "object",
            original_name: "CurCode"
          }
        ]
      end
    },
    RecurModelType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties:
            object_definitions['RecurRuleType'].map { |x| x.merge(name: 'RecurRule', label: 'RecurRule') },
            name: "RecurModelType",
            label: "RecurModelType",
            type: "object",
            original_name: "RecurModel"
          }
        ]
      end
    },
    RecurRuleType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties:
            [{"name" => "RecurType", "original_name" => "RecurType", "control_type" => "select", "options" => [ ["Cycle", "Cycle"], ["Monthly", "Monthly"], ["TwiceMonthly", "TwiceMonthly"], ["Quarterly", "Quarterly"], ["Yearly", "Yearly"], ["Weekly", "Weekly"], ["Once", "Once"], ["Maturity", "Maturity"] ], "location" => "request_body"}]
            .concat([{"name" => "RecurInterval", "original_name" => "RecurInterval", "type" => "integer", "control_type" => "integer", "convert_input" => "integer_conversion", "location" => "request_body"}])
            .concat([{"name" => "RecurStartDate", "original_name" => "RecurStartDate", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "Occurrences", "original_name" => "Occurrences", "type" => "integer", "control_type" => "integer", "location" => "request_body"}])
            .concat([{"name" => "RecurEndDate", "original_name" => "RecurEndDate", "type" => "date", "location" => "request_body"}]),
            name: "RecurRuleType",
            label: "RecurRuleType",
            type: "array",
            of: "object",
            original_name: "RecurRule"
          }
        ]
      end
    },
    ExtendedXferDataType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties:
            [{"name" => "XferAmtCode", "original_name" => "XferAmtCode", "control_type" => "text", "type" => "string", "location" => "request_body"}]
            .concat([{"name" => "ACHEntryClass", "original_name" => "ACHEntryClass", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat(object_definitions['NoticeDataType'].map { |x| x.merge(name: 'NoticeData', label: 'NoticeData') })
            .concat([{"name" => "ForcePostInd", "original_name" => "ForcePostInd", "control_type" => "checkbox", "type" => "boolean", "location" => "request_body"}])
            .concat([{"name" => "FeeIdent", "original_name" => "FeeIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}]),
            name: "ExtendedXferDataType",
            label: "ExtendedXferDataType",
            type: "object",
            original_name: "ExtendedXferData"
          }
        ]
      end
    },
    NoticeDataType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties:
            [{"name" => "NoticeType", "original_name" => "NoticeType", "control_type" => "select", "options" => [ ["RegularNotice", "RegularNotice"], ["ACHNotice", "ACHNotice"] ], "location" => "request_body"}]
            .concat([{"name" => "NoticeOption", "original_name" => "NoticeOption", "control_type" => "text", "type" => "string", "location" => "request_body"}]),
            name: "NoticeDataType",
            label: "NoticeDataType",
            type: "array",
            of: "object",
            original_name: "NoticeData"
          }
        ]
      end
    },
    RefDataType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties:
            [{"name" => "RefType", "original_name" => "RefType", "control_type" => "select", "options" => [ ["PayeeDesc", "PayeeDesc"], ["PayorDesc", "PayorDesc"] ], "location" => "request_body"}]
            .concat([{"name" => "RefIdent", "original_name" => "RefIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}]),
            name: "RefDataType",
            label: "RefDataType",
            type: "array",
            of: "object",
            original_name: "RefData"
          }
        ]
      end
    },
    XferStatusRecType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            object_definitions['XferKeysType'].map { |x| x.merge(name: 'XferKeys') }
            .concat(object_definitions['XferStatusType'].map { |x| x.merge(name: 'XferStatus', label: 'XferStatus') }),
            name: "XferStatusRecType",
            label: "XferStatusRecType",
            type: "object",
            original_name: "XferStatusRec"
          }
        ]
      end
    },
    XferKeysType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "XferId", "original_name" => "XferId", "control_type" => "text", "type" => "string", "location" => "request_body"}],
            name: "XferKeysType",
            label: "XferKeysType",
            type: "object",
            original_name: "XferKeys"
          }
        ]
      end
    },
    XferStatusType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "EffDt", "original_name" => "EffDt", "type" => "date", "location" => "request_body"}],
            name: "XferStatusType",
            label: "XferStatusType",
            type: "object",
            original_name: "XferStatus"
          }
        ]
      end
    },
    AcctTrnSelType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            object_definitions['AcctKeysType'].map { |x| x.merge(name: 'AcctKeys', lavel: 'AcctKeys') }
            .concat(object_definitions['ChkNumRangeType'].map { |x| x.merge(name: 'ChkNumRange', lavel: 'ChkNumRange') })
            .concat(object_definitions['CurAmtRangeType'].map { |x| x.merge(name: 'CurAmtRange', lavel: 'CurAmtRange') })
            .concat(object_definitions['DtRangeType'].map { |x| x.merge(name: 'DtRange', lavel: 'DtRange') })
            .concat([{"name" => "TrnPostType", "original_name" => "TrnPostType", "control_type" => "select", "options" => [ ["MemoPostOnly", "MemoPostOnly"], ["ExcludeMemoPost", "ExcludeMemoPost"], ["All", "All"] ], "location" => "request_body"}])
            .concat([{"name" => "IncRunningBalanceInd", "original_name" => "IncRunningBalanceInd", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
            .concat([{"name" => "IncReversalTrnInd", "original_name" => "IncReversalTrnInd", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
            .concat([{"name" => "PeriodType", "original_name" => "PeriodType", "control_type" => "select", "options" => [ ["15Days", "15Days"], ["30Days", "30Days"], ["60Days", "60Days"], ["90Days", "90Days"] ], "location" => "request_body"}])
            .concat(object_definitions['SortType'].map { |x| x.merge(name: 'Sort', lavel: 'Sort') })
            .concat(object_definitions['TrnCodeRangeType'].map { |x| x.merge(name: 'TrnCodeRange', lavel: 'TrnCodeRange') }),
            name: "AcctTrnSelType",
            label: "AcctTrnSelType",
            type: "object",
            original_name: "AcctTrnSel"
          }
        ]
      end
    },
    ChkNumRangeType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "ChkNumEnd", "original_name" => "ChkNumEnd", "type" => "date", "location" => "request_body"}]
            .concat([{"name" => "ChkNumStart", "original_name" => "ChkNumStart", "type" => "date", "location" => "request_body"}]),
            name: "ChkNumRangeType",
            label: "ChkNumRangeType",
            type: "object",
            original_name: "ChkNumRange"
          }
        ]
      end
    },
    CurAmtRangeType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            object_definitions['AmtRangeType'].map { |x| x.merge(name: 'HighCurAmt', label: 'HighCurAmt', original_name: 'HighCurAmt') }
            .concat(object_definitions['AmtRangeType'].map { |x| x.merge(name: 'LowCurAmt', label: 'LowCurAmt', original_name: 'LowCurAmt') }),
            name: "CurAmtRangeType",
            label: "CurAmtRangeType",
            type: "object",
            original_name: "CurAmtRange"
          }
        ]
      end
    },
    AmtRangeType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "Amt", "original_name" => "Amt", "type" => "number", "control_type" => "number", "convert_input" => "float_conversion", "location" => "request_body"}],
            name: "AmtRangeType",
            label: "AmtRangeType",
            type: "object",
            original_name: "AmtRange"
          }
        ]
      end
    },
    DtRangeType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "AddrType", "original_name" => "AddrType", "control_type" => "select", "options" => [ ["PostedDt", "PostedDt"] ], "location" => "request_body"}]
            .concat([{"name" => "StartDt", "original_name" => "StartDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "EndDt", "original_name" => "EndDt", "type" => "date", "location" => "request_body"}]),
            name: "DtRangeType",
            label: "DtRangeType",
            type: "array",
            of: "object",
            original_name: "DtRange"
          }
        ]
      end
    },
    SortType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "SortCriterionType", "original_name" => "SortCriterionType", "control_type" => "select", "options" => [ ["PostedDt", "PostedDt"], ["TrnCode", "TrnCode"], ["TrnAmt", "TrnAmt"] ], "location" => "request_body"}]
            .concat([{"name" => "SortOrder", "original_name" => "SortOrder", "control_type" => "text", "type" => "string", "location" => "request_body"}]),
            name: "SortType",
            label: "SortType",
            type: "array",
            of: "object",
            original_name: "Sort"
          }
        ]
      end
    },
    TrnCodeRangeType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "TrnCodeEnd", "original_name" => "TrnCodeEnd", "type" => "date", "location" => "request_body"}]
            .concat([{"name" => "TrnCodeStart", "original_name" => "TrnCodeStart", "type" => "date", "location" => "request_body"}]),
            name: "TrnCodeRangeType",
            label: "TrnCodeRangeType",
            type: "object",
            original_name: "TrnCodeRange"
          }
        ]
      end
    },
    AcctTrnRecType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            object_definitions['AcctTrnKeysType'].map { |x| x.merge(name: 'AcctTrnKeys', label: 'AcctTrnKeys', original_name: 'AcctTrnKeys') }
            .concat(object_definitions['AcctTrnInfoType'].map { |x| x.merge(name: 'AcctTrnInfo', label: 'AcctTrnInfo', original_name: 'AcctTrnInfo') })
            .concat(object_definitions['AcctTrnStatusType'].map { |x| x.merge(name: 'AcctTrnStatus', label: 'AcctTrnStatus', original_name: 'AcctTrnStatus') }),
            name: "AcctTrnRecType",
            label: "AcctTrnRecType",
            type: "array",
            of: "object",
            original_name: "AcctTrnRec"
          }
        ]
      end
    },
    AcctTrnKeysType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties:
            object_definitions['AcctKeysType'].map { |x| x.merge(name: 'AcctKeys', label: 'AcctKeys', original_name: 'AcctKeys') }
            .concat([{"name" => "AcctTrnIdent", "original_name" => "AcctTrnIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}]),
            name: "AcctTrnKeysType",
            label: "AcctTrnKeysType",
            type: "object",
            original_name: "AcctTrnKeys"
          }
        ]
      end
    },
    AcctTrnInfoType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties:
            [{"name" => "TrnCode", "original_name" => "TrnCode", "control_type" => "text", "type" => "string", "location" => "request_body"}]
            .concat([{"name" => "DrCrType", "original_name" => "DrCrType", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "DrCrTypeEnumDesc", "original_name" => "DrCrTypeEnumDesc", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "TrnRevType", "original_name" => "TrnRevType", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "TrnRevTypeEnumDesc", "original_name" => "TrnRevTypeEnumDesc", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "MemoPostInd", "original_name" => "MemoPostInd", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
            .concat([{"name" => "PostedDt", "original_name" => "PostedDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "PrincipalPaidToDt", "original_name" => "PrincipalPaidToDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "RateOverSplit", "original_name" => "RateOverSplit", "type" => "integer", "control_type" => "integer", "convert_input" => "integer_conversion", "location" => "request_body"}])
            .concat([{"name" => "RateUnderSplit", "original_name" => "RateUnderSplit", "type" => "integer", "control_type" => "integer", "convert_input" => "integer_conversion", "location" => "request_body"}])
            .concat(object_definitions['CurAmtType'].map { |x| x.merge(name: 'SplitRateAmt', label: 'SplitRateAmt', original_name: 'SplitRateAmt') })
            .concat(object_definitions['CurAmtType'].map { |x| x.merge(name: 'StmtRunningBal', label: 'StmtRunningBal', original_name: 'StmtRunningBal') })
            .concat([{"name" => "EffDt", "original_name" => "EffDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "TrnDt", "original_name" => "TrnDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "TrnType", "original_name" => "TrnType", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat(object_definitions['CurAmtType'].map { |x| x.merge(name: 'TrnAmt', label: 'TrnAmt', original_name: 'TrnAmt') })
            .concat([{"name" => "Desc", "original_name" => "Desc", "control_type" => "text", "type" => "array", "of" => "object", "location" => "request_body"}])
            .concat([{"name" => "ChkNum", "original_name" => "ChkNum", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "CSPRefIdent", "original_name" => "CSPRefIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat(object_definitions['CompositeCurAmtType'].map { |x| x.merge(name: 'CompositeCurAmt', label: 'CompositeCurAmt', original_name: 'CompositeCurAmt') })
            .concat([{"name" => "ExternalTrnCode", "original_name" => "ExternalTrnCode", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "ImageInd", "original_name" => "ImageInd", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
            .concat([{"name" => "IntPaidToDt", "original_name" => "IntPaidToDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "TrnImageId", "original_name" => "TrnImageId", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat(object_definitions['FloatDataType'].map { |x| x.merge(name: 'FloatData', label: 'FloatData', original_name: 'FloatData') }),
            
            name: "AcctTrnInfoType",
            label: "AcctTrnInfoType",
            type: "object",
            original_name: "AcctTrnInfo"
          }
        ]
      end
    },
    CompositeCurAmtType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "CompositeCurAmtType", "original_name" => "CompositeCurAmtType", "control_type" => "text", "type" => "string", "location" => "request_body"}]
            .concat(object_definitions['CurAmtType'].map { |x| x.merge(name: 'CurAmt', label: 'CurAmt', original_name: 'CurAmt') })
            .concat([{"name" => "SpecialHandling", "original_name" => "SpecialHandling", "control_type" => "text", "type" => "array", "of" => "object", "location" => "request_body"}]),
            name: "CompositeCurAmtType",
            label: "CompositeCurAmtType",
            type: "array",
            of: "object",
            original_name: "CompositeCurAmt"
          }
        ]
      end
    },
    FloatDataType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "FloatType", "original_name" => "FloatType", "control_type" => "text", "type" => "string", "location" => "request_body"}]
            .concat(object_definitions['FloatDetailsType'].map { |x| x.merge(name: 'FloatDetails', label: 'FloatDetails', original_name: 'FloatDetails') }),
            name: "FloatDataType",
            label: "FloatDataType",
            type: "array",
            of: "object",
            original_name: "FloatData"
          }
        ]
      end
    },
    FloatDetailsType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "FloatDays", "original_name" => "FloatDays", "type" => "integer", "control_type" => "integer", "convert_input" => "integer_conversion", "location" => "request_body"}]
            .concat(object_definitions['CurAmtType'].map { |x| x.merge(name: 'CheckFloatAmt', label: 'CheckFloatAmt', original_name: 'CheckFloatAmt') }),
            name: "FloatDetailsType",
            label: "FloatDetailsType",
            type: "array",
            of: "object",
            original_name: "FloatDetails"
          }
        ]
      end
    },
    AcctTrnStatusType: {
      fields: lambda do |_, _, object_definitions|
        [
          {
            properties: 
            [{"name" => "AcctTrnStatusCode", "original_name" => "AcctTrnStatusCode", "control_type" => "text", "type" => "string", "location" => "request_body"}]
            .concat([{"name" => "EffDt", "original_name" => "EffDt", "type" => "date", "location" => "request_body"}]),
            name: "AcctTrnRecType",
            label: "AcctTrnRecType",
            type: "object",
            original_name: "AcctTrnRec"
          }
        ]
      end
    },
    addAccount_input: {
      fields: lambda do |_, _, object_definitions|
          [{"name" => "OvrdAutoAckInd", "original_name" => "OvrdAutoAckInd", "control_type" => "checkbox", "type" => "boolean", "location" => "request_body"}]
          .concat(object_definitions['PartyAcctRelInfoType'].map { |x| x.merge(name: 'PartyAcctRelInfo', label: 'PartyAcctRelInfo', original_name: 'PartyAcctRelInfo', location: 'request_body') })
          .concat(object_definitions['DepositAcctInfoType'].map { |x| x.merge(name: 'DepositAcctInfo', label: 'DepositAcctInfo', original_name: 'DepositAcctInfo', location: 'request_body') })
          .concat(object_definitions['LoanAcctInfoType'].map { |x| x.merge(name: 'LoanAcctInfo', label: 'LoanAcctInfo', original_name: 'LoanAcctInfo', location: 'request_body') })
      end
    },

    addAccount_200_output: {
      fields: lambda do |_, _, object_definitions|
        object_definitions['StatusType'].map { |x| x.merge(name: 'Status')}
        .concat(object_definitions['AcctStatusRecType'].map { |x| x.merge(name: 'AcctStatusRec')})
      end
    },

    PartyAcctRelDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {
              "name" => "PartyAcctRelType",
              "original_name" => "PartyAcctRelType",
              "control_type" => "select",
              "pick_list" => [["Owner", "Owner"], ["OwnerSigner", "OwnerSigner"], ["Signer", "Signer"]],
              "type" => "string",
              "location" => "request_body"
            },
            {
              "name" => "PartyAcctRelOrder",
              "original_name" => "PartyAcctRelOrder",
              "control_type" => "select",
              "pick_list" => [["First", "First"], ["Second", "Second"], ["Third", "Third"]],
              "type" => "string",
              "location" => "request_body"
            }
          ],
          name: "PartyAcctRelDataType",
          label: "PartyAcctRelData",
          type: "array",
          of: "object",
          original_name: "PartyAcctRelData"
        }]
      end
    },

    IntDispDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {
              "name" => "IntDisposition",
              "original_name" => "IntDisposition",
              "control_type" => "select",
              "pick_list" => [["Capitalize", "Capitalize"], ["Transfer", "Transfer"], ["Check", "Check"]],
              "type" => "string",
              "location" => "request_body"
            }
          ].concat(object_definitions['AcctRefType'].map { |x| x.merge(name: 'IntDistAcctRef') }),
          name: "IntDispDataType",
          label: "IntDispData",
          type: "object",
          original_name: "IntDispData"
        }]
      end
    },

    RegCCDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {
              "name" => "RegCCStatusDt",
              "original_name" => "RegCCStatusDt",
              "type" => "date",
              "location" => "request_body"
            }
          ],
          name: "RegCCDataType",
          label: "RegCCData",
          type: "object",
          original_name: "RegCCData"
        }]
      end
    },

    AcctPrefType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {
              "name" => "Language",
              "original_name" => "Language",
              "control_type" => "select",
              "pick_list" => [["UseInstitution", "UseInstitution"], ["UsePortfolio", "UsePortfolio"], ["English", "English"], ["Spanish", "Spanish"]],
              "type" => "string",
              "location" => "request_body"
            }
          ],
          name: "AcctPrefType",
          label: "AcctPref",
          type: "object",
          original_name: "AcctPref"
        }]
      end
    },

    CurCodeType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {
              "name" => "CurCodeType",
              "original_name" => "CurCodeType",
              "control_type" => "text",
              "type" => "string",
              "location" => "request_body"
            },
            {
              "name" => "CurCodeValue",
              "original_name" => "CurCodeValue",
              "control_type" => "text",
              "type" => "string",
              "location" => "request_body"
            }
          ],
          name: "CurCodeType",
          label: "CurCode",
          type: "object",
          original_name: "CurCode"
        }]
      end
    },

    InitialAmountType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {
              "name" => "Amt",
              "original_name" => "Amt",
              "type" => "number",
              "control_type" => "number",
              "convert_input" => "float_conversion",
              "location" => "request_body"
            }
          ].concat(object_definitions['CurCodeType'].map { |x| x.merge(name: 'CurCode') }),
          name: "InitialAmountType",
          label: "InitialAmount",
          type: "object",
          original_name: "InitialAmount"
        }]
      end
    },

    AcctStmtDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {
              "name" => "StmtTimeFrame",
              "type" => "array",
              "of" => "object",
              "properties" => [
                {
                  "name" => "AlternateStmtInd",
                  "original_name" => "AlternateStmtInd",
                  "control_type" => "checkbox",
                  "type" => "boolean",
                  "convert_input" => "boolean_conversion",
                  "location" => "request_body"
                },
                {
                  "name" => "AlternateStmtOption",
                  "original_name" => "AlternateStmtOption",
                  "control_type" => "text",
                  "type" => "string",
                  "location" => "request_body"
                },
                {
                  "name" => "RecurType",
                  "original_name" => "RecurType",
                  "control_type" => "text",
                  "type" => "string",
                  "location" => "request_body"
                },
                {
                  "name" => "RecurInterval",
                  "original_name" => "RecurInterval",
                  "control_type" => "text",
                  "type" => "string",
                  "location" => "request_body"
                }
              ],
              "location" => "request_body",
              "original_name" => "StmtTimeFrame"
            },
            {
              "name" => "CombinedStmtIdent",
              "original_name" => "CombinedStmtIdent",
              "control_type" => "text",
              "type" => "string",
              "location" => "request_body"
            },
            {
              "name" => "CombinedStmtCode",
              "original_name" => "CombinedStmtCode",
              "control_type" => "text",
              "type" => "string",
              "location" => "request_body"
            },
            {
              "name" => "SpecialStmtCode",
              "original_name" => "SpecialStmtCode",
              "control_type" => "text",
              "type" => "string",
              "location" => "request_body"
            },
            {
              "name" => "StmtFormat",
              "original_name" => "StmtFormat",
              "control_type" => "text",
              "type" => "string",
              "location" => "request_body"
            },
            {
              "name" => "StmtTruncationOption",
              "original_name" => "StmtTruncationOption",
              "control_type" => "text",
              "type" => "string",
              "location" => "request_body"
            }
          ],
          name: "AcctStmtDataType",
          label: "AcctStmtData",
          type: "object",
          original_name: "AcctStmtData"
        }]
      end
    },

    NoticeDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {
              "name" => "NoticeType",
              "original_name" => "NoticeType",
              "control_type" => "text",
              "type" => "string",
              "location" => "request_body"
            },
            {
              "name" => "NoticeOption",
              "original_name" => "NoticeOption",
              "control_type" => "text",
              "type" => "string",
              "location" => "request_body"
            }
          ],
          name: "NoticeDataType",
          label: "NoticeData",
          type: "array",
          of: "object",
          original_name: "NoticeData"
        }]
      end
    },

    IntRateDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {
              "name" => "AccrualFrequency",
              "type" => "object",
              "properties" => [
                {
                  "name" => "RecurType",
                  "original_name" => "RecurType",
                  "control_type" => "text",
                  "type" => "string",
                  "location" => "request_body"
                },
                {
                  "name" => "RecurInterval",
                  "original_name" => "RecurInterval",
                  "control_type" => "text",
                  "type" => "string",
                  "location" => "request_body"
                }
              ],
              "location" => "request_body",
              "original_name" => "AccrualFrequency"
            },
            {
              "name" => "AccrualMethod",
              "original_name" => "AccrualMethod",
              "control_type" => "text",
              "type" => "string",
              "location" => "request_body"
            }
          ],
          name: "IntRateDataType",
          label: "IntRateData",
          type: "object",
          original_name: "IntRateData"
        }]
      end
    },

    RateChangeDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {
              "name" => "VarianceFactorType",
              "original_name" => "VarianceFactorType",
              "control_type" => "text",
              "type" => "string",
              "location" => "request_body"
            },
            {
              "name" => "RateFactor",
              "original_name" => "RateFactor",
              "type" => "number",
              "control_type" => "number",
              "convert_input" => "float_conversion",
              "location" => "request_body"
            }
          ],
          name: "RateChangeDataType",
          label: "RateChangeData",
          type: "array",
          of: "object",
          original_name: "RateChangeData"
        }]
      end
    },

    RelationshipMgrDepositType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {
              "name" => "RelationshipMgrIdent",
              "original_name" => "RelationshipMgrIdent",
              "control_type" => "text",
              "type" => "string",
              "location" => "request_body"
            },
            {
              "name" => "RelationshipRole",
              "original_name" => "RelationshipRole",
              "control_type" => "select",
              "pick_list" => [["Officer", "Officer"], ["SecondOfficer", "SecondOfficer"], ["ReferralOfficer", "ReferralOfficer"]],
              "type" => "string",
              "location" => "request_body"
            }
          ],
          name: "RelationshipMgrDepositType",
          label: "RelationshipMgr",
          type: "array",
          of: "object",
          original_name: "RelationshipMgr"
        }]
      end
    },

    PostAddrDepositType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "OpenDt", "original_name" => "OpenDt", "type" => "date", "location" => "request_body"},
            {"name" => "OriginatingBranch", "original_name" => "OriginatingBranch", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "ResponsibleBranch", "original_name" => "ResponsibleBranch", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "AddrFormatType", "original_name" => "AddrFormatType", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "Addr1", "original_name" => "Addr1", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "City", "original_name" => "City", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "StateProv", "original_name" => "StateProv", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "PostalCode", "original_name" => "PostalCode", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "AddrType", "original_name" => "AddrType", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "Retention", "original_name" => "Retention", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"},
            {"name" => "CensusTract", "original_name" => "CensusTract", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "CensusBlock", "original_name" => "CensusBlock", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "ForeignFlag", "original_name" => "ForeignFlag", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"},
            {"name" => "HandlingCode", "original_name" => "HandlingCode", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "HandlingCodeOption", "original_name" => "HandlingCodeOption", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "MSACode", "original_name" => "MSACode", "type" => "integer", "control_type" => "integer", "convert_input" => "integer_conversion", "location" => "request_body"},
            {
              "name" => "RelationshipMgr",
              "type" => "array",
              "of" => "object",
              "properties" => [
                {"name" => "RelationshipMgrIdent", "original_name" => "RelationshipMgrIdent", "control_type" => "text", "type" => "string", "location" => "request_body"},
                {"name" => "RelationshipRole", "original_name" => "RelationshipRole", "control_type" => "text", "type" => "string", "location" => "request_body"}
              ],
              "location" => "request_body",
              "original_name" => "RelationshipMgr"
            }
          ],
          name: "PostAddrDepositType",
          label: "PostAddr",
          type: "array",
          of: "object",
          original_name: "PostAddr"
        }]
      end
    },

    WithholdingDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "WithholdingType", "original_name" => "WithholdingType", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "WithholdingPercent", "original_name" => "WithholdingPercent", "type" => "number", "control_type" => "number", "convert_input" => "float_conversion", "location" => "request_body"}
          ],
          name: "WithholdingDataType",
          label: "WithholdingData",
          type: "array",
          of: "object",
          original_name: "WithholdingData"
        }]
      end
    },

    AcctMemoDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "AcctMemoIdent", "original_name" => "AcctMemoIdent", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "AcctMemoType", "original_name" => "AcctMemoType", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "AcctMemoText", "original_name" => "AcctMemoText", "control_type" => "text", "type" => "string", "location" => "request_body"}
          ],
          name: "AcctMemoDataType",
          label: "AcctMemoData",
          type: "array",
          of: "object",
          original_name: "AcctMemoData"
        }]
      end
    },
    

    PartyAcctRelInfoType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: 
            object_definitions['AcctRefType'].map { |x| x.merge(name: 'AcctRef') }
            .concat(object_definitions['PartyRefType'].map { |x| x.merge(name: 'PartyRef') })
            .concat(object_definitions['PartyAcctRelDataType'].map { |x| x.merge(name: 'PartyAcctRelData') })
            .concat([
              {"name" => "OwnerInd", "original_name" => "OwnerInd", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"},
              {"name" => "TaxReportingOwnerInd", "original_name" => "TaxReportingOwnerInd", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}
            ]),
          name: "PartyAcctRelInfo",
          label: "PartyAcctRelInfo",
          type: "array",
          of: "object",
          original_name: "PartyAcctRelInfo"
        }]
      end
    },

    AcctRefType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: object_definitions['AcctKeysType'].map { |x| x.merge(name: 'AcctKeys') },
          name: "AcctRefType",
          label: "AcctRef",
          type: "object",
          original_name: "AcctRef"
        }]
      end
    },

    PartyRefType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: object_definitions['PartyKeysType'].map { |x| x.merge(name: 'PartyKeys') },
          name: "PartyRefType",
          label: "PartyRef",
          type: "object",
          optional: "false",
          original_name: "PartyRef"
        }]
      end
    },

    AcctKeysType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "AcctId", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Account Identifier"},
            {"name" => "AcctType", "control_type" => "select", "pick_list" => [["DDA", "DDA"], ["SDA", "SDA"], ["CDA", "CDA"], ["LOAN", "LOAN"]], "type" => "string", "location" => "request_body"},
            {"name" => "AcctIdent", "type" => "array", "of" => "object", "properties" => [{"name" => "AcctIdentType", "control_type" => "text", "type" => "string", "location" => "request_body"}, {"name" => "AcctIdentValue", "control_type" => "text", "type" => "string", "location" => "request_body"}], "location" => "request_body"}
          ],
          name: "AcctKeysType",
          label: "AcctKeys",
          type: "object",
          original_name: "AcctKeys"
        }]
      end
    },

    DepositAcctInfoType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: 
            [{"name" => "ProductIdent", "original_name" => "ProductIdent", "control_type" => "text", "type" => "string", "location" => "request_body", "hint" => "Product Identifier"}]
            .concat([{"name" => "AcctType", "original_name" => "AcctType", "control_type" => "select", "pick_list" => [["DDA", "DDA"], ["SDA", "SDA"], ["CDA", "CDA"], ["CRD", "CRD"], ["LOAN", "LOAN"]], "type" => "string", "location" => "request_body"}])
            .concat(object_definitions['InitialAmountType'].map { |x| x.merge(name: 'InitialAmount') })
            .concat([{"name" => "OpenDt", "original_name" => "OpenDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "MaturityDt", "original_name" => "MaturityDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "Term", "original_name" => "Term", "type" => "object", "properties" => [{"name" => "Count", "original_name" => "Count", "control_type" => "text", "type" => "string", "location" => "request_body"}, {"name" => "TermUnits", "original_name" => "TermUnits", "control_type" => "select", "pick_list" => [["Days", "Days"], ["Months", "Months"], ["Years", "Years"]], "type" => "string", "location" => "request_body"}], "location" => "request_body"}])
            .concat(object_definitions['RelationshipMgrDepositType'].map { |x| x.merge(name: 'RelationshipMgr') })
            .concat([{"name" => "OriginatingBranch", "original_name" => "OriginatingBranch", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "ResponsibleBranch", "original_name" => "ResponsibleBranch", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "NicknameOption", "original_name" => "NicknameOption", "control_type" => "select", "pick_list" => [["Printed", "Printed"], ["NotPrinted", "NotPrinted"]], "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "Nickname", "original_name" => "Nickname", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "AcctTitle", "original_name" => "AcctTitle", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "AcctTitleOption", "original_name" => "AcctTitleOption", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "AcctDtlStatus", "original_name" => "AcctDtlStatus", "control_type" => "select", "pick_list" => [["Active", "Active"], ["Inactive", "Inactive"], ["Dormant", "Dormant"], ["ChargedOff", "ChargedOff"]], "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "AcctDtlStatusEnumDesc", "original_name" => "AcctDtlStatusEnumDesc", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "AcctOpenMethod", "original_name" => "AcctOpenMethod", "control_type" => "select", "pick_list" => [["InPerson", "InPerson"], ["Internet", "Internet"], ["Mail", "Mail"], ["Phone", "Phone"]], "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "TaxIncentiveType", "original_name" => "TaxIncentiveType", "control_type" => "select", "pick_list" => [["HSAFamily", "HSAFamily"], ["HSAIndividual", "HSAIndividual"], ["IRA", "IRA"], ["None", "None"]], "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "EscheatDt", "original_name" => "EscheatDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "CollateralPledgeCode", "original_name" => "CollateralPledgeCode", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "EIM_NSFInstruction", "original_name" => "EIM_NSFInstruction", "control_type" => "select", "pick_list" => [["Post", "Post"], ["Return", "Return"]], "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "AutoNSFDecision", "original_name" => "AutoNSFDecision", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "HandlingCode", "original_name" => "HandlingCode", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "HandlingCodeOption", "original_name" => "HandlingCodeOption", "control_type" => "select", "pick_list" => [["Statements", "Statements"], ["StatementsNotices", "StatementsNotices"], ["DoNotPrint", "DoNotPrint"]], "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "OEDCode", "original_name" => "OEDCode", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "AccountingMethod", "original_name" => "AccountingMethod", "control_type" => "select", "pick_list" => [["Class", "Class"], ["CostCenter", "CostCenter"], ["AcctType", "AcctType"]], "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "ClassCode", "original_name" => "ClassCode", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "AcctTypeCode", "original_name" => "AcctTypeCode", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "ProdIntRateId", "original_name" => "ProdIntRateId", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "Rate", "original_name" => "Rate", "type" => "number", "control_type" => "number", "convert_input" => "float_conversion", "location" => "request_body"}])
            .concat([{"name" => "IntReportingInd", "original_name" => "IntReportingInd", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
            .concat([{"name" => "RiskRanking", "original_name" => "RiskRanking", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "TrnRestriction", "original_name" => "TrnRestriction", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "TrnRestrictionOvrd", "original_name" => "TrnRestrictionOvrd", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "ElectronicBankingOpt", "original_name" => "ElectronicBankingOpt", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "ReportGroupCode", "original_name" => "ReportGroupCode", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "DocDistributionOption", "original_name" => "DocDistributionOption", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "NAICS", "original_name" => "NAICS", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "CostCenter", "original_name" => "CostCenter", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "RetentionOption", "original_name" => "RetentionOption", "control_type" => "select", "pick_list" => [["DoNotRetain", "DoNotRetain"], ["Retain", "Retain"]], "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "WithholdingOption", "original_name" => "WithholdingOption", "control_type" => "select", "pick_list" => [["None", "None"], ["StateTax", "StateTax"], ["FederalTax", "FederalTax"], ["StateFederalTax", "StateFederalTax"]], "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "NegotiableInstrumentInd", "original_name" => "NegotiableInstrumentInd", "control_type" => "checkbox", "type" => "boolean", "convert_input" => "boolean_conversion", "location" => "request_body"}])
            .concat([{"name" => "CheckNameOption", "original_name" => "CheckNameOption", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "ForfeitureCalcMethod", "original_name" => "ForfeitureCalcMethod", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "MemoPostProcessOptOvrd", "original_name" => "MemoPostProcessOptOvrd", "control_type" => "select", "pick_list" => [["Detail", "Detail"], ["Summary", "Summary"]], "type" => "string", "location" => "request_body"}])
            .concat(object_definitions['AcctPrefType'].map { |x| x.merge(name: 'AcctPref') })
            .concat(object_definitions['IntDispDataType'].map { |x| x.merge(name: 'IntDispData') })
            .concat(object_definitions['RegCCDataType'].map { |x| x.merge(name: 'RegCCData') })
            .concat(object_definitions['ClientDefinedDataType'].map { |x| x.merge(name: 'ClientDefinedData') })
            .concat(object_definitions['AcctStmtDataType'].map { |x| x.merge(name: 'AcctStmtData') })
            .concat(object_definitions['NoticeDataType'].map { |x| x.merge(name: 'NoticeData') })
            .concat(object_definitions['IntRateDataType'].map { |x| x.merge(name: 'IntRateData') })
            .concat(object_definitions['RateChangeDataType'].map { |x| x.merge(name: 'RateChangeData') })
            .concat(object_definitions['PostAddrDepositType'].map { |x| x.merge(name: 'PostAddr') })
            .concat(object_definitions['WithholdingDataType'].map { |x| x.merge(name: 'WithholdingData') })
            .concat(object_definitions['AcctMemoDataType'].map { |x| x.merge(name: 'AcctMemoData') })
            .concat(object_definitions['BeneficiaryDataType'].map { |x| x.merge(name: 'BeneficiaryData') })
            .concat(object_definitions['OverdraftDataType'].map { |x| x.merge(name: 'OverdraftData') })
            .concat(object_definitions['SvcChgDataType'].map { |x| x.merge(name: 'SvcChgData') })
            .concat(object_definitions['MaturityIntCalcDataType'].map { |x| x.merge(name: 'MaturityIntCalcData') })
            .concat(object_definitions['RenewalDataType'].map { |x| x.merge(name: 'RenewalData') })
            .concat(object_definitions['DateDataType'].map { |x| x.merge(name: 'DateData') })
            .concat(object_definitions['InterestBillingType'].map { |x| x.merge(name: 'InterestBilling') })
            .concat(object_definitions['LoanBillingType'].map { |x| x.merge(name: 'LoanBilling') }),
          name: "DepositAcctInfo",
          label: "DepositAcctInfo",
          type: "object",
          original_name: "DepositAcctInfo"
        }]
      end
    },


    LoanAcctInfoType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: 
            [{"name" => "ProductIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}]
            .concat([{"name" => "AcctType", "control_type" => "select", "pick_list" => [["LOAN", "LOAN"]], "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "InitialAmount", "type" => "object", "properties" => [{"name" => "Amt", "type" => "number", "control_type" => "number", "location" => "request_body"}, {"name" => "CurCode", "type" => "object", "properties" => [{"name" => "CurCodeType", "control_type" => "text", "type" => "string", "location" => "request_body"}, {"name" => "CurCodeValue", "control_type" => "text", "type" => "string", "location" => "request_body"}], "location" => "request_body"}], "location" => "request_body"}])
            .concat([{"name" => "OpenDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "MaturityDt", "type" => "date", "location" => "request_body"}])
            .concat([{"name" => "OriginationDt", "type" => "date", "location" => "request_body"}])
            .concat(object_definitions['RelationshipMgrType'].map { |x| x.merge(name: 'RelationshipMgr') })
            .concat([{"name" => "OriginatingBranch", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "ResponsibleBranch", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "AcctTitle", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "Nickname", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "NicknameOption", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "Rate", "type" => "number", "control_type" => "number", "location" => "request_body"}])
            .concat([{"name" => "TaxIdentType", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "TaxIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "NAICS", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "CostCenter", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "RevolvingLoanCode", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "CallReportCode", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "SecuredLoanInd", "control_type" => "checkbox", "type" => "boolean", "location" => "request_body"}])
            .concat([{"name" => "RiskRanking", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "ReportGroupCode", "control_type" => "text", "type" => "string", "location" => "request_body"}])
            .concat([{"name" => "AcctIdent", "type" => "array", "of" => "object", "properties" => [{"name" => "AcctIdentType", "control_type" => "text", "type" => "string", "location" => "request_body"}, {"name" => "AcctIdentValue", "control_type" => "text", "type" => "string", "location" => "request_body"}], "location" => "request_body"}])
            .concat(object_definitions['AcctPrefType'].map { |x| x.merge(name: 'AcctPref') })
            .concat(object_definitions['ClientDefinedDataType'].map { |x| x.merge(name: 'ClientDefinedData') })
            .concat(object_definitions['IntRateDataType'].map { |x| x.merge(name: 'IntRateData') })
            .concat(object_definitions['RateChangeDataType'].map { |x| x.merge(name: 'RateChangeData') })
            .concat(object_definitions['PostAddrType'].map { |x| x.merge(name: 'PostAddr') })
            .concat(object_definitions['CreditRiskType'].map { |x| x.merge(name: 'CreditRisk') })
            .concat(object_definitions['DateDataType'].map { |x| x.merge(name: 'DateData') })
            .concat(object_definitions['InterestBillingType'].map { |x| x.merge(name: 'InterestBilling') })
            .concat(object_definitions['LoanBillingType'].map { |x| x.merge(name: 'LoanBilling') })
            .concat(object_definitions['PmtSchedType'].map { |x| x.merge(name: 'PmtSched') })
            .concat(object_definitions['HomeMortgageDisclosureType'].map { |x| x.merge(name: 'HomeMortgageDisclosure') }),
          name: "LoanAcctInfo",
          label: "LoanAcctInfo",
          type: "object",
          original_name: "LoanAcctInfo"
        }]
      end
    },

    AcctStatusRecType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: object_definitions['AcctKeysType'].map { |x| x.merge(name: 'AcctKeys') }
            .concat(object_definitions['AcctStatusType'].map { |x| x.merge(name: 'AcctStatus') }),
          name: "AcctStatusRecType",
          label: "AcctStatusRec",
          type: "object",
          original_name: "AcctStatusRec"
        }]
      end
    },

    AcctStatusType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "AcctStatusCode", "control_type" => "text", "type" => "string"},
            {"name" => "EffDt", "type" => "date"}
          ],
          name: "AcctStatusType",
          label: "AcctStatus",
          type: "object",
          original_name: "AcctStatus"
        }]
      end
    },

    # Additional supporting types (simplified versions - expand as needed)
    AcctPrefType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [{"name" => "Language", "control_type" => "select", "pick_list" => [["UseInstitution", "UseInstitution"], ["UsePortfolio", "UsePortfolio"], ["English", "English"], ["Spanish", "Spanish"]], "type" => "string", "location" => "request_body"}],
          name: "AcctPrefType",
          label: "AcctPref",
          type: "object",
          original_name: "AcctPref"
        }]
      end
    },

    IntDispDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "IntDisposition", "control_type" => "select", "pick_list" => [["Capitalize", "Capitalize"], ["Transfer", "Transfer"]], "type" => "string", "location" => "request_body"},
            {"name" => "IntDistAcctRef", "type" => "object", "properties" => object_definitions['AcctKeysType'].map { |x| x.merge(name: 'AcctKeys') }, "location" => "request_body"}
          ],
          name: "IntDispDataType",
          label: "IntDispData",
          type: "object",
          original_name: "IntDispData"
        }]
      end
    },

    RegCCDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "RegCCStatusDt", "type" => "date", "location" => "request_body"},
            {"name" => "RegCCStatus", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "RegCCException", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "RegCCExceptionExpDt", "type" => "date", "location" => "request_body"}
          ],
          name: "RegCCDataType",
          label: "RegCCData",
          type: "object",
          original_name: "RegCCData"
        }]
      end
    },

    AcctStmtDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "StmtTimeFrame", "type" => "array", "of" => "object", "properties" => [{"name" => "AlternateStmtInd", "control_type" => "checkbox", "type" => "boolean", "location" => "request_body"}, {"name" => "AlternateStmtOption", "control_type" => "text", "type" => "string", "location" => "request_body"}, {"name" => "RecurType", "control_type" => "text", "type" => "string", "location" => "request_body"}, {"name" => "RecurInterval", "control_type" => "text", "type" => "string", "location" => "request_body"}], "location" => "request_body"},
            {"name" => "LastStmtDt", "type" => "date", "location" => "request_body"},
            {"name" => "CombinedStmtIdent", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "CombinedStmtCode", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "SpecialStmtCode", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "StmtFormat", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "StmtTruncationOption", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "StmtGroup", "control_type" => "text", "type" => "string", "location" => "request_body"}
          ],
          name: "AcctStmtDataType",
          label: "AcctStmtData",
          type: "object",
          original_name: "AcctStmtData"
        }]
      end
    },

    NoticeDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "NoticeType", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "NoticeOption", "control_type" => "text", "type" => "string", "location" => "request_body"}
          ],
          name: "NoticeDataType",
          label: "NoticeData",
          type: "array",
          of: "object",
          original_name: "NoticeData"
        }]
      end
    },

    IntRateDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "AccrualFrequency", "type" => "object", "properties" => [{"name" => "RecurType", "control_type" => "text", "type" => "string", "location" => "request_body"}, {"name" => "RecurInterval", "control_type" => "text", "type" => "string", "location" => "request_body"}], "location" => "request_body"},
            {"name" => "AccrualMethod", "control_type" => "select", "pick_list" => [["Daily", "Daily"], ["Simple", "Simple"], ["PrincipalAndInterest", "PrincipalAndInterest"]], "type" => "string", "location" => "request_body"},
            {"name" => "APYRecurType", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "AccrualCode", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "BasedOnCode", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "DailyAccrual", "control_type" => "text", "type" => "string", "location" => "request_body"}
          ],
          name: "IntRateDataType",
          label: "IntRateData",
          type: "object",
          original_name: "IntRateData"
        }]
      end
    },

    RateChangeDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "VarianceFactorType", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "RateFactor", "type" => "number", "control_type" => "number", "location" => "request_body"},
            {"name" => "FloorRate", "type" => "number", "control_type" => "number", "location" => "request_body"},
            {"name" => "CeilingRate", "type" => "number", "control_type" => "number", "location" => "request_body"},
            {"name" => "RateVariance", "type" => "number", "control_type" => "number", "location" => "request_body"},
            {"name" => "IncreaseOnlyInd", "control_type" => "checkbox", "type" => "boolean", "location" => "request_body"},
            {"name" => "RateChangeControl", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "RateChangeRecurType", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "RecurInterval", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "LeadDays", "type" => "integer", "control_type" => "integer", "location" => "request_body"},
            {"name" => "NextRateChangeDt", "type" => "date", "location" => "request_body"},
            {"name" => "RoundingOption", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "RoundingFactor", "type" => "number", "control_type" => "number", "location" => "request_body"}
          ],
          name: "RateChangeDataType",
          label: "RateChangeData",
          type: "array",
          of: "object",
          original_name: "RateChangeData"
        }]
      end
    },

    WithholdingDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "WithholdingType", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "WithholdingPercent", "type" => "number", "control_type" => "number", "location" => "request_body"}
          ],
          name: "WithholdingDataType",
          label: "WithholdingData",
          type: "array",
          of: "object",
          original_name: "WithholdingData"
        }]
      end
    },

    AcctMemoDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "AcctMemoIdent", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "AcctMemoType", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "AcctMemoText", "control_type" => "text", "type" => "string", "location" => "request_body"}
          ],
          name: "AcctMemoDataType",
          label: "AcctMemoData",
          type: "array",
          of: "object",
          original_name: "AcctMemoData"
        }]
      end
    },

    BeneficiaryDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "PartyKeys", "type" => "object", "properties" => [{"name" => "PartyId", "control_type" => "text", "type" => "string", "location" => "request_body"}], "location" => "request_body"},
            {"name" => "PostAddr", "type" => "object", "properties" => [{"name" => "AddressIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}, {"name" => "AddrType", "control_type" => "text", "type" => "string", "location" => "request_body"}], "location" => "request_body"},
            {"name" => "BeneficiaryType", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "BeneficiaryPercent", "type" => "number", "control_type" => "number", "location" => "request_body"}
          ],
          name: "BeneficiaryDataType",
          label: "BeneficiaryData",
          type: "array",
          of: "object",
          original_name: "BeneficiaryData"
        }]
      end
    },

    OverdraftDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "OverdraftEnrollOpt", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "OverdraftAutoTrnInd", "control_type" => "checkbox", "type" => "boolean", "location" => "request_body"},
            {"name" => "OverdraftLimitPriority", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "OverdraftLimitAmt", "type" => "object", "properties" => [{"name" => "Amt", "type" => "number", "control_type" => "number", "location" => "request_body"}], "location" => "request_body"},
            {"name" => "OverdraftRatingCode", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "OverdraftTypeCode", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "AtmPosOverdraft", "type" => "object", "properties" => [{"name" => "AuthLimitOption", "control_type" => "text", "type" => "string", "location" => "request_body"}, {"name" => "OptInOutDt", "type" => "date", "location" => "request_body"}, {"name" => "AuthLimitAmt", "type" => "object", "properties" => [{"name" => "Amt", "type" => "number", "control_type" => "number", "location" => "request_body"}], "location" => "request_body"}, {"name" => "NoticeOption", "control_type" => "text", "type" => "string", "location" => "request_body"}], "location" => "request_body"}
          ],
          name: "OverdraftDataType",
          label: "OverdraftData",
          type: "object",
          original_name: "OverdraftData"
        }]
      end
    },

    SvcChgDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "CreditBackAcct", "type" => "array", "of" => "object", "properties" => [{"name" => "CreditBackIdent", "control_type" => "text", "type" => "string", "location" => "request_body"}], "location" => "request_body"}
          ],
          name: "SvcChgDataType",
          label: "SvcChgData",
          type: "object",
          original_name: "SvcChgData"
        }]
      end
    },

    MaturityIntCalcDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "MaturityIntRateType", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "MaturityIntRate", "type" => "number", "control_type" => "number", "location" => "request_body"},
            {"name" => "MaturityIntInterval", "type" => "integer", "control_type" => "integer", "location" => "request_body"}
          ],
          name: "MaturityIntCalcDataType",
          label: "MaturityIntCalcData",
          type: "object",
          original_name: "MaturityIntCalcData"
        }]
      end
    },

    RenewalDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "RenewalOption", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "RenewalProductIdent", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "RenewalRate", "type" => "number", "control_type" => "number", "location" => "request_body"}
          ],
          name: "RenewalDataType",
          label: "RenewalData",
          type: "object",
          original_name: "RenewalData"
        }]
      end
    },

    DateDataType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "DateType", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "DateValue", "type" => "date", "location" => "request_body"}
          ],
          name: "DateDataType",
          label: "DateData",
          type: "array",
          of: "object",
          original_name: "DateData"
        }]
      end
    },

    InterestBillingType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "RecurModel", "type" => "object", "properties" => [{"name" => "RecurRule", "type" => "array", "of" => "object", "properties" => [{"name" => "RecurType", "control_type" => "text", "type" => "string", "location" => "request_body"}, {"name" => "RecurInterval", "type" => "integer", "control_type" => "integer", "location" => "request_body"}, {"name" => "RecurStartDate", "type" => "date", "location" => "request_body"}], "location" => "request_body"}], "location" => "request_body"}
          ],
          name: "InterestBillingType",
          label: "InterestBilling",
          type: "object",
          original_name: "InterestBilling"
        }]
      end
    },

    LoanBillingType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "BillingMethod", "control_type" => "text", "type" => "string", "location" => "request_body"}
          ],
          name: "LoanBillingType",
          label: "LoanBilling",
          type: "object",
          original_name: "LoanBilling"
        }]
      end
    },

    PmtSchedType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "PmtSchedIdent", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "RecurModel", "type" => "object", "properties" => [{"name" => "RecurRule", "type" => "array", "of" => "object", "properties" => [{"name" => "RecurType", "control_type" => "text", "type" => "string", "location" => "request_body"}, {"name" => "RecurInterval", "type" => "integer", "control_type" => "integer", "location" => "request_body"}, {"name" => "RecurStartDate", "type" => "date", "location" => "request_body"}, {"name" => "Occurrences", "type" => "integer", "control_type" => "integer", "location" => "request_body"}], "location" => "request_body"}], "location" => "request_body"},
            {"name" => "NumberOfTimes", "type" => "integer", "control_type" => "integer", "location" => "request_body"},
            {"name" => "PmtAmtOption", "control_type" => "text", "type" => "string", "location" => "request_body"},
            {"name" => "SuppressNoticeInd", "control_type" => "checkbox", "type" => "boolean", "location" => "request_body"},
            {"name" => "CurAmt", "type" => "object", "properties" => [{"name" => "Amt", "type" => "number", "control_type" => "number", "location" => "request_body"}, {"name" => "CurCode", "type" => "object", "properties" => [{"name" => "CurCodeType", "control_type" => "text", "type" => "string", "location" => "request_body"}, {"name" => "CurCodeValue", "control_type" => "text", "type" => "string", "location" => "request_body"}], "location" => "request_body"}], "location" => "request_body"}
          ],
          name: "PmtSchedType",
          label: "PmtSched",
          type: "array",
          of: "object",
          original_name: "PmtSched"
        }]
      end
    },

    HomeMortgageDisclosureType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {"name" => "PostAddr", "type" => "object", "properties" => [{"name" => "County", "control_type" => "text", "type" => "string", "location" => "request_body"}], "location" => "request_body"},
            {"name" => "MortgageReportingData", "type" => "array", "of" => "object", "properties" => [{"name" => "ReportingType", "control_type" => "text", "type" => "string", "location" => "request_body"}], "location" => "request_body"}
          ],
          name: "HomeMortgageDisclosureType",
          label: "HomeMortgageDisclosure",
          type: "object",
          original_name: "HomeMortgageDisclosure"
        }]
      end
    },
    AcctKeysType_Required: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: [
            {
              name: 'AcctId',
              label: 'Account ID',
              original_name: 'AcctId',
              control_type: 'text',
              type: 'string',
              optional: false,
              hint: 'Account Identifier. Required to identify the account.'
            },
            {
              name: 'AcctType',
              label: 'Account Type',
              original_name: 'AcctType',
              control_type: 'select',
              pick_list: [['DDA', 'DDA'], ['SDA', 'SDA'], ['CDA', 'CDA'], ['LOAN', 'LOAN']],
              type: 'string',
              optional: false,
              hint: 'Account Type. Required to identify the account.'
            }
          ],
          name: 'AcctKeys',
          label: 'Account Keys',
          type: 'object',
          original_name: 'AcctKeys'
        }]
      end
    },
    AcctSelType: {
      fields: lambda do |_, _, object_definitions|
        [{
          properties: object_definitions['AcctKeysType_Required'].map { |x| x.merge(name: 'AcctKeys', original_name: 'AcctKeys') },
          name: 'AcctSel',
          label: 'Account Selection',
          type: 'object',
          original_name: 'AcctSel'
        }]
      end
    },
  },
  
  ################################
  # METHODS
  ################################
  methods: {
    format_api_request: lambda do |input, input_schema|
      request_payload = {}

      actual_input = call(:transform_keys_to_original_name, input_schema, input)
      input_with_location = call(:add_location_to_input, input_schema, actual_input)

      actual_input.each do |original_name, data|
        stored_values = request_payload[data[:location]] || {}
        request_payload[data[:location]] = stored_values.merge(original_name => data[:value])
      end

      # Format cookies into semicolon separated string and add to headers
      if request_payload["cookie"]
        request_payload["cookie"] = call(:format_cookies, request_payload["cookie"])
        request_payload["header"] = (request_payload["header"] || {}).deep_merge({ "Cookie" => request_payload["cookie"]} )
      end

      request_payload
    end,
    parse_array_fields: lambda do |input|
      if input.is_a?(Hash)
        input.each_with_object({}) do |(key, value), result|
          if value.is_a?(String) && value.start_with?('[{') && value.end_with?('}]')            
            begin
              require 'json'
              result[key] = JSON.parse(value.gsub('=>', ':'))
            rescue
              result[key] = value
            end
          elsif value.is_a?(Hash)
            result[key] = call(:parse_array_fields, value)
          elsif value.is_a?(Array)
            result[key] = value.map { |item| item.is_a?(Hash) ? call(:parse_array_fields, item) : item }
          else
            result[key] = value
          end
        end
      elsif input.is_a?(Array)
        input.map { |item| item.is_a?(Hash) ? call(:parse_array_fields, item) : item }
      else
        input
      end
    end,
    format_cookies: lambda do |cookies|
      cookie_string = []
      cookies.map do |key, value|
        cookie_string = cookie_string.concat(["#{key}=#{value}"])
      end
      cookie_string.smart_join("; ")
    end,
    format_url_endpoint: lambda do |request_payload, url|
      final_url = url
      if request_payload["path"].present?
        request_payload["path"].map do |key,value|
          final_url = final_url.gsub("{#{key}}",value)
        end
      end
      final_url
    end,
    clear_name: lambda do |data|
      hash_data = { root: data }
      call('recursive_clear_name!', hash_data)[:root]
    end,
    recursive_clear_name!: lambda do |hash_data|
      hash_data.clone.each do |_key, value|
        if value.is_a?(Hash)
          call('recursive_clear_name!', value)
        elsif value.is_a?(Array) && value.first.is_a?(Hash)
          value.map { |v| call('recursive_clear_name!', v) }
        elsif hash_data[:name]&.to_s =~ /W/
          hash_data[:name] = hash_data[:name]&.to_s&.gsub(/W/, '_')
        end
      end
    end,
    transform_keys_to_original_name: lambda do |input_schema, input|
      transformed_hash = {}
      input.each do |key, value|
        source_input = element = call(:recursively_find_hash_by_name, input_schema, key)
        next if source_input.nil?
        new_key = source_input[:original_name].presence || key

        if value.is_a?(Hash)
          transformed_hash[new_key] = call(:transform_keys_to_original_name, input_schema, value)
        elsif value.is_a?(Array)
          transformed_hash[new_key] = value.map { |item| item.is_a?(Hash) ? call(:transform_keys_to_original_name, input_schema, item) : item }
        else
          transformed_hash[new_key] = value
        end
      end

      transformed_hash
    end,
    add_location_to_input: lambda do |input_schema, actual_input|
      actual_input.each do |key, value|
        source_input = call(:recursively_find_hash_by_original_name, input_schema, key)
        location = source_input[:location]

        actual_input[key] = { location: location, value: value }
      end

      actual_input
    end,
    recursively_find_hash_by_name: lambda do |input_schema, name|
      if input_schema.is_a?(Hash) && input_schema['name'] == name
        input_schema
      elsif input_schema.is_a?(Hash)
        input_schema.values.map { |x| call(:recursively_find_hash_by_name, x, name) }.compact.first
      elsif input_schema.is_a?(Array)
        input_schema.map { |x| call(:recursively_find_hash_by_name, x, name) }.compact.first
      end
    end,
    recursively_find_hash_by_original_name: lambda do |input_schema, name|
      if input_schema.is_a?(Hash) && input_schema['original_name'] == name
        input_schema
      elsif input_schema.is_a?(Hash)
        input_schema.values.map { |x| call(:recursively_find_hash_by_original_name, x, name) }.compact.first
      elsif input_schema.is_a?(Array)
        input_schema.map { |x| call(:recursively_find_hash_by_original_name, x, name) }.compact.first
      end
    end,
    UpdateParty_execute: lambda do |_connection, input, extended_input_schema|
      url = "#{_connection['host_path']}/parties"
      request_payload = call('format_api_request', input, extended_input_schema)

      url = call('format_url_endpoint', request_payload, url)

      put(url).request_format_json
        .params(request_payload['query'] || {})
        .payload(request_payload['request_body'] || {})
        .headers(request_payload['header'] || {})
        .after_response do |_code, body, headers|
          {
            payload: body,
            headers: headers
          }
      end
    end,
    addParty_execute: lambda do |_connection, input, extended_input_schema|
      url = "#{_connection['host_path']}/partyservice/parties/parties"
      request_payload = call('format_api_request', input, extended_input_schema)

      url = call('format_url_endpoint', request_payload, url)

      post(url).request_format_json
        .params(request_payload['query'] || {})
        .payload(request_payload['request_body'] || {})
        .headers(request_payload['header'] || {})
        .after_response do |_code, body, headers|
          {
            payload: body,
            headers: headers
          }
      end
    end,
    getPartyInqSecure_execute: lambda do |_connection, input, extended_input_schema|
      url = "#{_connection['host_path']}/partyservice/parties/parties/secured"
      request_payload = call('format_api_request', input, extended_input_schema)

      url = call('format_url_endpoint', request_payload, url)

      post(url).request_format_json
        .params(request_payload['query'] || {})
        .payload(request_payload['request_body'] || {})
        .headers(request_payload['header'] || {})
        .after_response do |_code, body, headers|
          {
            payload: body,
            headers: headers
          }
      end
    end,
    getPartyListInqSecured_execute: lambda do |_connection, input, extended_input_schema|
      url = "#{_connection['host_path']}/partyservice/parties/parties/secured/list"
      request_payload = call('format_api_request', input, extended_input_schema)

      url = call('format_url_endpoint', request_payload, url)

      post(url).request_format_json
        .params(request_payload['query'] || {})
        .payload(request_payload['request_body'] || {})
        .headers(request_payload['header'] || {})
        .after_response do |_code, body, headers|
          {
            payload: body,
            headers: headers
          }
      end
    end,
    addTransfer_execute: lambda do |_connection, input, extended_input_schema|
      url = "#{_connection['host_path']}/xferservice/payments/transfers"
      request_payload = call('format_api_request', input, extended_input_schema)

      url = call('format_url_endpoint', request_payload, url)

      post(url).request_format_json
        .params(request_payload['query'] || {})
        .payload(request_payload['request_body'] || {})
        .headers(request_payload['header'] || {})
        .after_response do |_code, body, headers|
          {
            payload: body,
            headers: headers
          }
      end
    end,
    getAccountTransactions_execute: lambda do |_connection, input, extended_input_schema|
      url = "#{_connection['host_path']}/accttranservice/acctmgmt/acctTrn/secured"
      request_payload = call('format_api_request', input, extended_input_schema)

      url = call('format_url_endpoint', request_payload, url)

      post(url).request_format_json
        .params(request_payload['query'] || {})
        .payload(request_payload['request_body'] || {})
        .headers(request_payload['header'] || {})
        .after_response do |_code, body, headers|
          {
            payload: body,
            headers: headers
          }
      end
    end,
    addAccount_execute: lambda do |_connection, input, extended_input_schema|
      url = "#{_connection['host_path']}/acctservice/acctmgmt/accounts"
      request_payload = call('format_api_request', input, extended_input_schema)
      
      # Get the AcctIdentValue to determine the payload structure
      acct_type = input['AcctIdentValue_request_body']
      
      # Build the payload based on account type
      final_payload = request_payload['request_body'] || {}

      # Parse any stringified arrays back to proper arrays
      final_payload = call(:parse_array_fields, final_payload)
      
      # Remove the AcctIdentValue from the payload as it's just for routing logic
      final_payload.delete('AcctIdentValue')
      
      # Set the AcctType in the appropriate section based on account type
      if ['DDA', 'SDA', 'CDA'].include?(acct_type) && final_payload['DepositAcctInfo']
        final_payload['DepositAcctInfo']['AcctType'] = acct_type
      elsif acct_type == 'LOAN' && final_payload['LoanAcctInfo']
        final_payload['LoanAcctInfo']['AcctType'] = acct_type
      end
      
      url = call('format_url_endpoint', request_payload, url)

      post(url).request_format_json
        .params(request_payload['query'] || {})
        .payload(final_payload)
        .headers(request_payload['header'] || {})
        .after_response do |_code, body, headers|
          {
            payload: body,
            headers: headers
          }
      end
    end,
  },
  
  ################################
  # ACTIONS
  ################################
  actions: {
    UpdateParty: {
      title: "PARTY SERVICE: Modify party (customer) information",
      hint: "Modify party (customer) information in Party Service",
      subtitle: "Modify party (customer) information in Party Service",
      help: "This service operation modifies party (customer) information.",
      input_fields: lambda do |object_definitions|
        object_definitions['UpdateParty_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['UpdateParty_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:UpdateParty_execute, connection, input, extended_input_schema)
      end
    },
    addParty: {
      title: "PARTY SERVICE: Add a Party (customer)",
      hint: "Add a Party (customer) in Party Service",
      subtitle: "Add a Party (customer) in Party Service",
      help: "This service operation adds a party (customer).",
      input_fields: lambda do |object_definitions|
        object_definitions['addParty_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['addParty_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:addParty_execute, connection, input, extended_input_schema)
      end
    },
    getPartyInqSecure: {
      title: "PARTY SERVICE: Retrieve party (customer) information",
      hint: "Retrieve party (customer) information in Party Service",
      subtitle: "Retrieve party (customer) information in Party Service",
      help: "This service operation retrieves party (customer) information.",
      input_fields: lambda do |object_definitions|
        object_definitions['getPartyInqSecure_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['getPartyInqSecure_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:getPartyInqSecure_execute, connection, input, extended_input_schema)
      end
    },
    getPartyListInqSecured: {
      title: "PARTY SERVICE: Retrieves a list of parties (customers)",
      hint: "Retrieves a list of parties (customers) in Party Service",
      subtitle: "Retrieves a list of parties (customers) in Party Service",
      help: "This service operation retrieves a list of parties based on various search criteria such as name, address, issued identification, social security number, etc.",
      input_fields: lambda do |object_definitions|
        object_definitions['getPartyListInqSecured_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['getPartyListInqSecured_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:getPartyListInqSecured_execute, connection, input, extended_input_schema)
      end
    },
    addTransactionBetweenAccts: {
      title: "TRANSFER SERVICE: Add transfer",
      hint: "Performs transfers between two accounts",
      subtitle: "Performs transfers between two accounts",
      help: "",
      input_fields: lambda do |object_definitions|
        object_definitions['addTransfer_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['addTransfer_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:addTransfer_execute, connection, input, extended_input_schema)
      end
    },
    getAccountTransactions: {
      title: "ACCOUNT TRANSACTION SERVICE: get account transactions (acct history)",
      hint: "Performs transfers between two accounts",
      subtitle: "Get Account Transaction History API retrieves the transaction history",
      help: "For Premier, this API returns both memo post (pending) transactions and hard posted transactions for the current and previous statement cycle only from the Core and not from an auxiliary storage like AMS. It also returns reversed transactions. This API does not include a selection criterion to filter pending vs posted transactions and does not return running balances.
      No parameter configuration is needed for this API.",
      input_fields: lambda do |object_definitions|
        object_definitions['getAccountTransactions_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['getAccountTransactions_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:getAccountTransactions_execute, connection, input, extended_input_schema)
      end
    },
    add_account: {
      title: "ACCOUNTS: Add Account",
      hint: "Creates a new account in Fiserv Premier Banking Hub",
      subtitle: "Creates a new account in Fiserv Premier Banking Hub",
      help: "This action adds a new account in Fiserv Premier banking core. Select the account type (DDA, SDA, CDA, LOAN) and provide the required information. Each account type has different required fields.",
      input_fields: lambda do |object_definitions|
        object_definitions['addAccount_input']
      end,
      output_fields: lambda do |object_definitions|
        object_definitions['addAccount_200_output']
      end,
      execute: lambda do |connection, input, extended_input_schema|
        call(:addAccount_execute, connection, input, extended_input_schema)
      end
    },
    updateAccount: {
      title: "ACCOUNTS: Update Account",
      description: "Update an existing account in Fiserv Premier Banking Hub",
      
      input_fields: lambda do |object_definitions|
        # Use the required AcctKeys object definition
        object_definitions["AcctKeysType_Required"].map { |x| x.merge(name: "AcctKeys", label: "Account Keys (Required)", location: "request_body") }
          .concat([{
            name: "OvrdAutoAckInd",
            original_name: "OvrdAutoAckInd",
            control_type: "checkbox",
            type: "boolean",
            location: "request_body",
            hint: "Override AutoAcknowledge Indicator."
          }])
          .concat(object_definitions["PartyAcctRelInfoType"].map { |x| x.merge(name: "PartyAcctRelInfo", label: "PartyAcctRelInfo", original_name: "PartyAcctRelInfo", location: "request_body") })
          .concat(object_definitions["DepositAcctInfoType"].map { |x| x.merge(name: "DepositAcctInfo", label: "DepositAcctInfo", original_name: "DepositAcctInfo", location: "request_body") })
          .concat(object_definitions["LoanAcctInfoType"].map { |x| x.merge(name: "LoanAcctInfo", label: "LoanAcctInfo", original_name: "LoanAcctInfo", location: "request_body") })
      end,
      
      execute: lambda do |_connection, input, extended_input_schema|
        # Use PUT method for updates
        url = "#{_connection["host_path"]}/acctservice/acctmgmt/accounts"
        request_payload = call("format_api_request", input, extended_input_schema)
        
        # Build the payload
        final_payload = request_payload["request_body"] || {}
        
        # Parse any stringified arrays back to proper arrays
        final_payload = call(:parse_array_fields, final_payload)
        
        # Remove the AcctIdentValue from the payload if present
        final_payload.delete("AcctIdentValue")
        
        url = call("format_url_endpoint", request_payload, url)

        # Use PUT for update operations
        put(url).request_format_json
          .params(request_payload["query"] || {})
          .payload(final_payload)
          .headers(request_payload["header"] || {})
          .after_response do |_code, body, headers|
            {
              payload: body,
              headers: headers
            }
          end
      end,
      
      output_fields: lambda do |object_definitions|
        # Reuse the same output structure as addAccount
        object_definitions["StatusType"].map { |x| x.merge(name: "Status")}
          .concat(object_definitions["AcctStatusRecType"].map { |x| x.merge(name: "AcctStatusRec")})
      end
    },
    getAccount: {
      title: "ACCOUNTS: Get Account",
      description: "Retrieve account information from Fiserv Premier Banking Hub",
      
      input_fields: lambda do |object_definitions|
        # Use the AcctSel object definition which contains required AcctKeys
        object_definitions["AcctSelType"].map { |x| x.merge(name: "AcctSel", location: "request_body") }
      end,
      
      execute: lambda do |_connection, input, extended_input_schema|
        # Use POST method with /secured endpoint for Get operations
        url = "#{_connection["host_path"]}/acctservice/acctmgmt/accounts/secured"
        request_payload = call("format_api_request", input, extended_input_schema)
        
        # Get the payload
        final_payload = request_payload["request_body"] || {}
        
        url = call("format_url_endpoint", request_payload, url)
        
        # Make the POST request to the /secured endpoint
        post(url).request_format_json
          .payload(final_payload)
          .headers(request_payload["header"] || {})
          .after_response do |_code, body, headers|
            {
              payload: body,
              headers: headers
            }
          end
      end,
      
      output_fields: lambda do |object_definitions|
        # Return Status and AcctRec with full account details
        object_definitions["StatusType"].map { |x| x.merge(name: "Status") }
          .concat([{
            name: "AcctRec",
            label: "Account Record",
            type: "object",
            properties: 
              object_definitions["AcctKeysType"].map { |x| x.merge(name: "AcctKeys") }
              .concat(object_definitions["AcctStatusRecType"].map { |x| x.merge(name: "AcctStatus") })
              .concat(object_definitions["DepositAcctInfoType"].map { |x| x.merge(name: "DepositAcctInfo") })
              .concat(object_definitions["LoanAcctInfoType"].map { |x| x.merge(name: "LoanAcctInfo") })
              .concat(object_definitions["PartyAcctRelInfoType"].map { |x| x.merge(name: "PartyAcctRelInfo") })
          }])
      end
    }
  }
}