{
  title: 'Ajera Connector - V1',

  connection: {
    fields: [
      {
        name: 'APIUserName',
        optional: false,
      },
      {
        name: 'APIUserPassword',
        #control_type: 'password',
        optional: false,
      },
      {
        name: 'CustomerId',
        optional: false,
      },
      #{
      #  name: 'client_id',
      #  optional: true,
      #},
      {
        name: 'ClientUrlKey',
        #control_type: 'password',
        optional: false,
      },
      #{
      #  name: 'APIVersion',
      #  control_type: 'number',
      #  optional: false,
      #},
    ],

    authorization: {
      type: 'custom_auth', #Set to custom_auth

      acquire: lambda do |connection|

        {
          SessionToken: post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
            payload(Method: "CreateAPISession",
              Username: "#{connection['APIUserName']}",
              Password: "#{connection['APIUserPassword']}",
              APIVersion: 1,
              UseSessionCookie: false).
            dig('Content', 'SessionToken')
        }

      end,

      refresh_on: [401, 403, /Unable to authenticate user/, /Invalid Session/],

      detect_on: [/Unable to authenticate user/, /Invalid Session/],

      apply: lambda do |connection|
        payload(SessionToken: connection['SessionToken'])
      end
    },

    base_uri: lambda do |connection|
      'https://ajera.com'
    end

  },

  test: lambda do |connection|
    post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
      payload(Method: "ListClients",
        #SessionToken: connection['SessionToken'],
        MethodArguments:  {
          "FilterByEarliestModifiedDate":"2023-04-01",
          "FilterByLatestModifiedDate":"2023-04-11" })
  end,



  actions: {

    list_clients: {
      title: "CLIENTS - List Clients",
      subtitle: "List Clients returns an array of Clients",

      input_fields: lambda do |object_definitions|
        [
          #           {
          #             name: "FilterByCompany",
          #             label: "Filter By Company",
          #             hint: "Filter By Company",
          #             type: "array",
          #             of: "integer",
          #             optional: true
          #           },
          #           {
          #             name: "FilterByStatus",
          #             label: "Filter by Status",
          #             hint: "Filter by Status",
          #             type: "array",
          #             of: "string",
          #             optional: true
          #           },
          #           {
          #             name: "FilterByNameLike",
          #             label: "Filter by Name Like",
          #             hint: "Filter by Name Like",
          #             optional: true
          #           },
          #           {
          #             name: "FilterByNameEquals",
          #             label: "Filter by Name Equals",
          #             hint: "Filter by Name Equals",
          #             optional: true
          #           },
          #           {
          #             name: "FilterByClientType",
          #             label: "Filter by ClientType",
          #             hint: "Filter by Client Type",
          #             type: "array",
          #             of: "integer",
          #             optional: true
          #           },
          {
            name: "FilterByEarliestModifiedDate",
            label: "Earliest Modified Date",
            hint: "Filter By Earliest Modified Date Eg. format 2015-03-11 16:22:54.229 GMT-0700",
            type: "string",
            optional: true
          },
          {
            name: "FilterByLatestModifiedDate",
            label: "Latest Modfied Date",
            hint: "Filter By Latest Modified Date Eg. format 2015-03-11 16:22:54.229 GMT-0700.",
            type: "string",
            optional: true
          },
        ]
      end,

      execute: lambda do |connection, input|
        post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
          payload(Method: "ListClients",
            #SessionToken: connection['SessionToken'],
            MethodArguments:  {
              #"FilterByCompany": input["FilterByCompany"],
              #               "FilterByStatus": input["FilterByStatus"],
              #               "FilterByNameLike": input["FilterByNameLike"],
              #               "FilterByNameEquals": input["FilterByNameEquals"],
              #               "FilterByClientType": input["FilterByClientType"],
              "FilterByEarliestModifiedDate": input["FilterByEarliestModifiedDate"],
              "FilterByLatestModifiedDate": input["FilterByLatestModifiedDate"] }
          )
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:clients_output]
      end
    },

    get_clients: {
      title: "CLIENTS - Get Clients",
      subtitle: "Get Clients takes one or more key values, and returns an array of matching Clients",

      input_fields: lambda do |object_definitions|
        [
          {
            name: "RequestedClients",
            label: "Requested Clients",
            type: "array",
            of: "integer",
            optional: false
          },
        ]
      end,

      execute: lambda do |connection, input|
        post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
          payload(Method: "GetClients",
            #SessionToken: connection['SessionToken'],
            MethodArguments:  {
              "RequestedClients": input["RequestedClients"] }
          )
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:clients_detail_output]
      end
    },

    list_contacts: {
      title: "CONTACTS - List Contacts",
      subtitle: "List Contacts returns an array of Contacts",

      input_fields: lambda do |object_definitions|
        [
          #           {
          #             name: "FilterByCompany",
          #             label: "Filter By Company",
          #             hint: "Filter By Company",
          #             type: "array",
          #             of: "integer",
          #             optional: true
          #           },
          #           {
          #             name: "FilterByStatus",
          #             label: "Filter by Status",
          #             hint: "Filter by Status",
          #             type: "array",
          #             of: "string",
          #             optional: true
          #           },
          #           {
          #             name: "FilterByText",
          #             label: "Filter by Text",
          #             hint: "Filter by Text",
          #             optional: true
          #           },
          #           {
          #             name: "FilterByContactType",
          #             label: "Filter by ContactType",
          #             hint: "Filter by Contact Type",
          #             type: "array",
          #             of: "integer",
          #             optional: true
          #           },
          {
            name: "FilterByEarliestModifiedDate",
            label: "Earliest Modified Date",
            hint: "Filter By Earliest Modified Date Eg. format 2015-03-11 16:22:54.229 GMT-0700",
            type: "date",
            optional: true
          },
          {
            name: "FilterByLatestModifiedDate",
            label: "Latest Modfied Date",
            hint: "Filter By Latest Modified Date Eg. format 2015-03-11 16:22:54.229 GMT-0700",
            type: "date",
            optional: true
          },
        ]
      end,

      execute: lambda do |connection, input|
        post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
          payload(Method: "ListContacts",
            #SessionToken: connection['SessionToken'],
            MethodArguments:  {
              #               "FilterByCompany": input["FilterByCompany"],
              #               "FilterByStatus": input["FilterByStatus"],
              #               "FilterByText": input["FilterByText"],
              #               "FilterByContactType": input["FilterByContactType"],
              "FilterByEarliestModifiedDate": input["FilterByEarliestModifiedDate"],
              "FilterByLatestModifiedDate": input["FilterByLatestModifiedDate"] }
          )
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:contacts_output]
      end
    },

    get_contacts: {
      title: "CONTACTS - Get Contacts",
      subtitle: "Get Contacts takes one or more key values, and returns an array of matching Contacts",

      input_fields: lambda do |object_definitions|
        [
          {
            name: "RequestedContacts",
            label: "Requested Contacts",
            type: "array",
            of: "integer",
            optional: false
          },
        ]
      end,

      execute: lambda do |connection, input|
        post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
          payload(Method: "GetContacts",
            #SessionToken: connection['SessionToken'],
            MethodArguments:  {
              "RequestedContacts": input["RequestedContacts"] }
          )
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:contacts_detail_output]
      end
    },

    get_vendors: {
      title: "VENDORS - Get Vendors",
      subtitle: "Get Vendors takes one or more key values, and returns an array of matching Vendors",

      input_fields: lambda do |object_definitions|
        [
          {
            name: "RequestedVendors",
            label: "Requested Vendors",
            type: "array",
            of: "integer",
            optional: false
          },
        ]
      end,

      execute: lambda do |connection, input|
        post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
          payload(Method: "GetVendors",
            #SessionToken: connection['SessionToken'],
            MethodArguments:  {
              "RequestedVendors": input["RequestedVendors"] }
          )
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:vendors_detail_output]
      end
    },

    list_pays: {
      title: "VARIOUS LIST METHODS - List Pays",
      subtitle: "List payments",

      input_fields: lambda do |object_definitions|
        [
          {
            name: "FilterByStatus",
            label: "Filter By Status",
            type: "array",
            of: "string",
            hint: "string array, optional, (either 'Active' or 'Inactive', case-insensitive)"
          }
        ]
      end,

      execute: lambda do |connection, input|
        post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
          payload(
            Method: "ListPays",
            #SessionToken: connection['SessionToken'],
            MethodArguments:  {
              "FilterByStatus": input["FilterByStatus"]
            }
          )
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:list_pays_output]
      end
    },
    
    list_vendors: {
      title: "VENDORS - List Vendors",
      subtitle: "List Vendors returns an array of Vendors",

      input_fields: lambda do |object_definitions|
        [
          #           {
          #             name: "FilterByCompany",
          #             label: "Filter By Company",
          #             hint: "Filter By Company",
          #             type: "array",
          #             of: "integer",
          #             optional: true
          #           },
          #           {
          #             name: "FilterByStatus",
          #             label: "Filter by Status",
          #             hint: "Filter by Status",
          #             type: "array",
          #             of: "string",
          #             optional: true
          #           },
          #           {
          #             name: "FilterByNameLike",
          #             label: "Filter by Name Like",
          #             hint: "Filter by Name Like",
          #             optional: true
          #           },
          #           {
          #             name: "FilterByNameEquals",
          #             label: "Filter by Name Equals",
          #             hint: "Filter by Name Equals",
          #             optional: true
          #           },
          #           {
          #             name: "FilterByClientType",
          #             label: "Filter by ClientType",
          #             hint: "Filter by Client Type",
          #             type: "array",
          #             of: "integer",
          #             optional: true
          #           },
          {
            name: "FilterByEarliestModifiedDate",
            label: "Earliest Modified Date",
            hint: "Filter By Earliest Modified Date Eg. format 2015-03-11 16:22:54.229 GMT-0700",
            type: "string",
            optional: true
          },
          {
            name: "FilterByLatestModifiedDate",
            label: "Latest Modfied Date",
            hint: "Filter By Latest Modified Date Eg. format 2015-03-11 16:22:54.229 GMT-0700.",
            type: "string",
            optional: true
          },
        ]
      end,

      execute: lambda do |connection, input|
        post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
          payload(Method: "ListVendors",
            #SessionToken: connection['SessionToken'],
            MethodArguments:  {
              #"FilterByCompany": input["FilterByCompany"],
              #               "FilterByStatus": input["FilterByStatus"],
              #               "FilterByNameLike": input["FilterByNameLike"],
              #               "FilterByNameEquals": input["FilterByNameEquals"],
              #               "FilterByClientType": input["FilterByClientType"],
              "FilterByEarliestModifiedDate": input["FilterByEarliestModifiedDate"],
              "FilterByLatestModifiedDate": input["FilterByLatestModifiedDate"] }
          )
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:vendors_output]
      end
    },

  },

  triggers: {

    new_updated_clients: {
      title: "New/Updated Clients",
      subtitle: "Polling trigger set to 1 a day",

      input_fields: lambda do
        [
          { name: 'since', type: :timestamp, optional: false },
        ]
      end,

      poll: lambda do |connection, input, closure, _eis, _eos|

        closure = {} unless closure.present? # initialize the closure hash when recipe is first started.

        updated_since = (closure['cursor'] || input['since'] || Time.now ).to_time.utc.iso8601

        clients = post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
          payload(Method: "ListClients",
            #SessionToken: connection['SessionToken'],
            MethodArguments:  {
              "FilterByLatestModifiedDate": input["since"].strftime("%Y-%m-%d") })

        next_updated_since = updated_since + 1.day.from_now

        {
          events: clients,
          next_poll: next_updated_since
        }
      end,

      dedup: lambda do |events|
        "#{events['id']}" + 1.second.from_now.to_s
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:clients_output]
      end
    },

    new_updated_contacts: {
      title: "New/Updated Contacts",
      subtitle: "Polling trigger set to 1 a day",

      input_fields: lambda do
        [
          { name: 'since', type: :timestamp, optional: false },
        ]
      end,

      poll: lambda do |connection, input, closure, _eis, _eos|

        closure = {} unless closure.present? # initialize the closure hash when recipe is first started.

        updated_since = (closure['cursor'] || input['since'] || Time.now ).to_time.utc.iso8601

        clients = post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
          payload(Method: "ListContacts",
            #SessionToken: connection['SessionToken'],
            MethodArguments:  {
              "FilterByLatestModifiedDate": input["since"].strftime("%Y-%m-%d") })

        next_updated_since = updated_since + 1.day.from_now

        {
          events: clients,
          next_poll: next_updated_since
        }
      end,

      dedup: lambda do |events|
        "#{events['id']}" + 1.second.from_now.to_s
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:contacts_output]
      end
    },
    
  },

  object_definitions: {
    clients_output: {
      fields: lambda do
        [
          {
            "control_type": "number",
            "label": "Response code",
            "parse_output": "float_conversion",
            "type": "number",
            "name": "ResponseCode"
          },
          {
            "control_type": "text",
            "label": "Message",
            "type": "string",
            "name": "Message"
          },
          {
            "properties": [
              {
                "name": "Clients",
                "type": "array",
                "of": "object",
                "label": "Clients",
                "properties": [
                  {
                    "control_type": "number",
                    "label": "Client key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ClientKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Description",
                    "type": "string",
                    "name": "Description"
                  }
                ]
              }
            ],
            "label": "Content",
            "type": "object",
            "name": "Content"
          },
          {
            "control_type": "text",
            "label": "Usage key",
            "type": "string",
            "name": "UsageKey"
          }
        ]
      end
    },

    contacts_output: {
      fields: lambda do
        [
          {
            "control_type": "number",
            "label": "Response code",
            "parse_output": "float_conversion",
            "type": "number",
            "name": "ResponseCode"
          },
          {
            "control_type": "text",
            "label": "Message",
            "type": "string",
            "name": "Message"
          },
          {
            "properties": [
              {
                "name": "Contacts",
                "type": "array",
                "of": "object",
                "label": "Contacts",
                "properties": [
                  {
                    "control_type": "number",
                    "label": "Contact key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ContactKey"
                  },
                  {
                    "control_type": "text",
                    "label": "First name",
                    "type": "string",
                    "name": "FirstName"
                  },
                  {
                    "control_type": "text",
                    "label": "Middle name",
                    "type": "string",
                    "name": "MiddleName"
                  },
                  {
                    "control_type": "text",
                    "label": "Last name",
                    "type": "string",
                    "name": "LastName"
                  },
                  {
                    "control_type": "text",
                    "label": "Company",
                    "type": "string",
                    "name": "Company"
                  },
                  {
                    "control_type": "text",
                    "label": "Contact client key",
                    "type": "string",
                    "name": "ContactClientKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Contact vendor key",
                    "type": "string",
                    "name": "ContactVendorKey"
                  }
                ]
              }
            ],
            "label": "Content",
            "type": "object",
            "name": "Content"
          },
          {
            "control_type": "text",
            "label": "Usage key",
            "type": "string",
            "name": "UsageKey"
          }
        ]
      end
    },

    clients_detail_output:{
      fields: lambda do
        [
          {
            "control_type": "number",
            "label": "Response code",
            "parse_output": "float_conversion",
            "type": "number",
            "name": "ResponseCode"
          },
          {
            "control_type": "text",
            "label": "Message",
            "type": "string",
            "name": "Message"
          },
          {
            "properties": [
              {
                "name": "Clients",
                "type": "array",
                "of": "object",
                "label": "Clients",
                "properties": [
                  {
                    "control_type": "number",
                    "label": "Client key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ClientKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Status",
                    "type": "string",
                    "name": "Status"
                  },
                  {
                    "control_type": "text",
                    "label": "Description",
                    "type": "string",
                    "name": "Description"
                  },
                  {
                    "control_type": "text",
                    "label": "Date established",
                    "type": "string",
                    "name": "DateEstablished"
                  },
                  {
                    "control_type": "text",
                    "label": "Send statements",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Send statements",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "SendStatements"
                    },
                    "type": "boolean",
                    "name": "SendStatements"
                  },
                  {
                    "control_type": "text",
                    "label": "Create finance charge",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Create finance charge",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "CreateFinanceCharge"
                    },
                    "type": "boolean",
                    "name": "CreateFinanceCharge"
                  },
                  {
                    "control_type": "number",
                    "label": "Annual percentage rate",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "AnnualPercentageRate"
                  },
                  {
                    "control_type": "number",
                    "label": "Pre payment beginning balance",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "PrePaymentBeginningBalance"
                  },
                  {
                    "control_type": "text",
                    "label": "Account ID",
                    "type": "string",
                    "name": "AccountID"
                  },
                  {
                    "control_type": "text",
                    "label": "Fax number",
                    "type": "string",
                    "name": "FaxNumber"
                  },
                  {
                    "control_type": "text",
                    "label": "Fax description",
                    "type": "string",
                    "name": "FaxDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary phone number",
                    "type": "string",
                    "name": "PrimaryPhoneNumber"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary phone description",
                    "type": "string",
                    "name": "PrimaryPhoneDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Secondary phone number",
                    "type": "string",
                    "name": "SecondaryPhoneNumber"
                  },
                  {
                    "control_type": "text",
                    "label": "Secondary phone description",
                    "type": "string",
                    "name": "SecondaryPhoneDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Tertiary phone number",
                    "type": "string",
                    "name": "TertiaryPhoneNumber"
                  },
                  {
                    "control_type": "text",
                    "label": "Tertiary phone description",
                    "type": "string",
                    "name": "TertiaryPhoneDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Email",
                    "type": "string",
                    "name": "Email"
                  },
                  {
                    "control_type": "text",
                    "label": "Website",
                    "type": "string",
                    "name": "Website"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address line one",
                    "type": "string",
                    "name": "PrimaryAddressLineOne"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address line two",
                    "type": "string",
                    "name": "PrimaryAddressLineTwo"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address line three",
                    "type": "string",
                    "name": "PrimaryAddressLineThree"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address city",
                    "type": "string",
                    "name": "PrimaryAddressCity"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address zip",
                    "type": "string",
                    "name": "PrimaryAddressZip"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address state",
                    "type": "string",
                    "name": "PrimaryAddressState"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address country",
                    "type": "string",
                    "name": "PrimaryAddressCountry"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address same as primary",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Mailing address same as primary",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "MailingAddressSameAsPrimary"
                    },
                    "type": "boolean",
                    "name": "MailingAddressSameAsPrimary"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address line one",
                    "type": "string",
                    "name": "MailingAddressLineOne"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address line two",
                    "type": "string",
                    "name": "MailingAddressLineTwo"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address line three",
                    "type": "string",
                    "name": "MailingAddressLineThree"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address city",
                    "type": "string",
                    "name": "MailingAddressCity"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address zip",
                    "type": "string",
                    "name": "MailingAddressZip"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address state",
                    "type": "string",
                    "name": "MailingAddressState"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address country",
                    "type": "string",
                    "name": "MailingAddressCountry"
                  },
                  {
                    "control_type": "text",
                    "label": "Notes",
                    "type": "string",
                    "name": "Notes"
                  },
                  {
                    "control_type": "number",
                    "label": "Client type key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ClientTypeKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Client type description",
                    "type": "string",
                    "name": "ClientTypeDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Client type notes",
                    "type": "string",
                    "name": "ClientTypeNotes"
                  },
                  {
                    "control_type": "text",
                    "label": "Last modified date",
                    "type": "string",
                    "name": "LastModifiedDate"
                  },
                  {
                    "control_type": "number",
                    "label": "Email statement template key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "EmailStatementTemplateKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Email statement template description",
                    "type": "string",
                    "name": "EmailStatementTemplateDescription"
                  }
                ]
              }
            ],
            "label": "Content",
            "type": "object",
            "name": "Content"
          },
          {
            "control_type": "text",
            "label": "Usage key",
            "type": "string",
            "name": "UsageKey"
          }
        ]
      end,
    },

    contacts_detail_output:{
      fields: lambda do
        [
          {
            "control_type": "number",
            "label": "Response code",
            "parse_output": "float_conversion",
            "type": "number",
            "name": "ResponseCode"
          },
          {
            "control_type": "text",
            "label": "Message",
            "type": "string",
            "name": "Message"
          },
          {
            "properties": [
              {
                "name": "Contacts",
                "type": "array",
                "of": "object",
                "label": "Contacts",
                "properties": [
                  {
                    "control_type": "number",
                    "label": "Contact key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ContactKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Status",
                    "type": "string",
                    "name": "Status"
                  },
                  {
                    "control_type": "text",
                    "label": "First name",
                    "type": "string",
                    "name": "FirstName"
                  },
                  {
                    "control_type": "text",
                    "label": "Middle name",
                    "type": "string",
                    "name": "MiddleName"
                  },
                  {
                    "control_type": "text",
                    "label": "Last name",
                    "type": "string",
                    "name": "LastName"
                  },
                  {
                    "control_type": "text",
                    "label": "Company",
                    "type": "string",
                    "name": "Company"
                  },
                  {
                    "control_type": "text",
                    "label": "Title",
                    "type": "string",
                    "name": "Title"
                  },
                  {
                    "control_type": "text",
                    "label": "Fax number",
                    "type": "string",
                    "name": "FaxNumber"
                  },
                  {
                    "control_type": "text",
                    "label": "Fax description",
                    "type": "string",
                    "name": "FaxDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Email",
                    "type": "string",
                    "name": "Email"
                  },
                  {
                    "control_type": "text",
                    "label": "Website",
                    "type": "string",
                    "name": "Website"
                  },
                  {
                    "control_type": "text",
                    "label": "Notes",
                    "type": "string",
                    "name": "Notes"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address line one",
                    "type": "string",
                    "name": "PrimaryAddressLineOne"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address line two",
                    "type": "string",
                    "name": "PrimaryAddressLineTwo"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address line three",
                    "type": "string",
                    "name": "PrimaryAddressLineThree"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address city",
                    "type": "string",
                    "name": "PrimaryAddressCity"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address zip",
                    "type": "string",
                    "name": "PrimaryAddressZip"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address state",
                    "type": "string",
                    "name": "PrimaryAddressState"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address country",
                    "type": "string",
                    "name": "PrimaryAddressCountry"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address same as primary",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Mailing address same as primary",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "MailingAddressSameAsPrimary"
                    },
                    "type": "boolean",
                    "name": "MailingAddressSameAsPrimary"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address line one",
                    "type": "string",
                    "name": "MailingAddressLineOne"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address line two",
                    "type": "string",
                    "name": "MailingAddressLineTwo"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address line three",
                    "type": "string",
                    "name": "MailingAddressLineThree"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address city",
                    "type": "string",
                    "name": "MailingAddressCity"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address zip",
                    "type": "string",
                    "name": "MailingAddressZip"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address state",
                    "type": "string",
                    "name": "MailingAddressState"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address country",
                    "type": "string",
                    "name": "MailingAddressCountry"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary phone number",
                    "type": "string",
                    "name": "PrimaryPhoneNumber"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary phone description",
                    "type": "string",
                    "name": "PrimaryPhoneDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Secondary phone number",
                    "type": "string",
                    "name": "SecondaryPhoneNumber"
                  },
                  {
                    "control_type": "text",
                    "label": "Secondary phone description",
                    "type": "string",
                    "name": "SecondaryPhoneDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Tertiary phone number",
                    "type": "string",
                    "name": "TertiaryPhoneNumber"
                  },
                  {
                    "control_type": "text",
                    "label": "Tertiary phone description",
                    "type": "string",
                    "name": "TertiaryPhoneDescription"
                  },
                  {
                    "control_type": "number",
                    "label": "Contact type key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ContactTypeKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Contact type description",
                    "type": "string",
                    "name": "ContactTypeDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Contact type notes",
                    "type": "string",
                    "name": "ContactTypeNotes"
                  },
                  {
                    "control_type": "text",
                    "label": "Contact client key",
                    "type": "string",
                    "name": "ContactClientKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Contact client description",
                    "type": "string",
                    "name": "ContactClientDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Contact vendor key",
                    "type": "string",
                    "name": "ContactVendorKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Contact vendor description",
                    "type": "string",
                    "name": "ContactVendorDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Last modified date",
                    "type": "string",
                    "name": "LastModifiedDate"
                  }
                ]
              }
            ],
            "label": "Content",
            "type": "object",
            "name": "Content"
          },
          {
            "control_type": "text",
            "label": "Usage key",
            "type": "string",
            "name": "UsageKey"
          }
        ]
      end,
    },

    vendors_detail_output:{
      fields: lambda do
        [
          {
            "control_type": "number",
            "label": "Response code",
            "parse_output": "float_conversion",
            "type": "number",
            "name": "ResponseCode"
          },
          {
            "control_type": "text",
            "label": "Message",
            "type": "string",
            "name": "Message"
          },
          {
            "properties": [
              {
                "name": "Vendors",
                "type": "array",
                "of": "object",
                "label": "Vendors",
                "properties": [
                  {
                    "control_type": "number",
                    "label": "Vendor key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "VendorKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Name",
                    "type": "string",
                    "name": "Name"
                  },
                  {
                    "control_type": "text",
                    "label": "Status",
                    "type": "string",
                    "name": "Status"
                  },
                  {
                    "control_type": "text",
                    "label": "Date established",
                    "type": "string",
                    "name": "DateEstablished"
                  },
                  {
                    "control_type": "text",
                    "label": "Receives 1099 form",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Receives 1099 form",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "Receives1099Form"
                    },
                    "type": "boolean",
                    "name": "Receives1099Form"
                  },
                  {
                    "control_type": "text",
                    "label": "Form type 1099",
                    "type": "string",
                    "name": "FormType1099"
                  },
                  {
                    "control_type": "text",
                    "label": "Recipient ID 1099",
                    "type": "string",
                    "name": "RecipientID1099"
                  },
                  {
                    "control_type": "text",
                    "label": "Recipient name 1099",
                    "type": "string",
                    "name": "RecipientName1099"
                  },
                  {
                    "control_type": "number",
                    "label": "Reported amount 1099",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ReportedAmount1099"
                  },
                  {
                    "control_type": "number",
                    "label": "Federal tax witheld",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "FederalTaxWitheld"
                  },
                  {
                    "control_type": "text",
                    "label": "Receives W 9 form",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Receives W 9 form",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "ReceivesW9Form"
                    },
                    "type": "boolean",
                    "name": "ReceivesW9Form"
                  },
                  {
                    "control_type": "text",
                    "label": "Buisness type W 9",
                    "type": "string",
                    "name": "BuisnessTypeW9"
                  },
                  {
                    "control_type": "text",
                    "label": "Other description W 9",
                    "type": "string",
                    "name": "OtherDescriptionW9"
                  },
                  {
                    "control_type": "text",
                    "label": "Department key",
                    "type": "string",
                    "name": "DepartmentKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Department description",
                    "type": "string",
                    "name": "DepartmentDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Account key",
                    "type": "string",
                    "name": "AccountKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Account description",
                    "type": "string",
                    "name": "AccountDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Account ID",
                    "type": "string",
                    "name": "AccountID"
                  },
                  {
                    "control_type": "text",
                    "label": "Vendor account ID",
                    "type": "string",
                    "name": "VendorAccountID"
                  },
                  {
                    "control_type": "text",
                    "label": "Calculate payment date method",
                    "type": "string",
                    "name": "CalculatePaymentDateMethod"
                  },
                  {
                    "control_type": "number",
                    "label": "Number of days from invoice date",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "NumberOfDaysFromInvoiceDate"
                  },
                  {
                    "control_type": "number",
                    "label": "Day of the month to pay",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "DayOfTheMonthToPay"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary phone number",
                    "type": "string",
                    "name": "PrimaryPhoneNumber"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary phone description",
                    "type": "string",
                    "name": "PrimaryPhoneDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Secondary phone number",
                    "type": "string",
                    "name": "SecondaryPhoneNumber"
                  },
                  {
                    "control_type": "text",
                    "label": "Secondary phone description",
                    "type": "string",
                    "name": "SecondaryPhoneDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Tertiary phone number",
                    "type": "string",
                    "name": "TertiaryPhoneNumber"
                  },
                  {
                    "control_type": "text",
                    "label": "Tertiary phone description",
                    "type": "string",
                    "name": "TertiaryPhoneDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Fax number",
                    "type": "string",
                    "name": "FaxNumber"
                  },
                  {
                    "control_type": "text",
                    "label": "Fax description",
                    "type": "string",
                    "name": "FaxDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Email",
                    "type": "string",
                    "name": "Email"
                  },
                  {
                    "control_type": "text",
                    "label": "Website",
                    "type": "string",
                    "name": "Website"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address line one",
                    "type": "string",
                    "name": "PrimaryAddressLineOne"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address line two",
                    "type": "string",
                    "name": "PrimaryAddressLineTwo"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address line three",
                    "type": "string",
                    "name": "PrimaryAddressLineThree"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address city",
                    "type": "string",
                    "name": "PrimaryAddressCity"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address zip",
                    "type": "string",
                    "name": "PrimaryAddressZip"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address state",
                    "type": "string",
                    "name": "PrimaryAddressState"
                  },
                  {
                    "control_type": "text",
                    "label": "Primary address country",
                    "type": "string",
                    "name": "PrimaryAddressCountry"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address same as primary",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Mailing address same as primary",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "MailingAddressSameAsPrimary"
                    },
                    "type": "boolean",
                    "name": "MailingAddressSameAsPrimary"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address line one",
                    "type": "string",
                    "name": "MailingAddressLineOne"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address line two",
                    "type": "string",
                    "name": "MailingAddressLineTwo"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address line three",
                    "type": "string",
                    "name": "MailingAddressLineThree"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address city",
                    "type": "string",
                    "name": "MailingAddressCity"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address zip",
                    "type": "string",
                    "name": "MailingAddressZip"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address state",
                    "type": "string",
                    "name": "MailingAddressState"
                  },
                  {
                    "control_type": "text",
                    "label": "Mailing address country",
                    "type": "string",
                    "name": "MailingAddressCountry"
                  },
                  {
                    "name": "Contacts",
                    "type": "array",
                    "of": "object",
                    "label": "Contacts",
                    "properties": [
                      {
                        "control_type": "number",
                        "label": "Contact key",
                        "parse_output": "float_conversion",
                        "type": "number",
                        "name": "ContactKey"
                      },
                      {
                        "control_type": "text",
                        "label": "Text",
                        "type": "string",
                        "name": "Text"
                      },
                      {
                        "control_type": "text",
                        "label": "First name",
                        "type": "string",
                        "name": "FirstName"
                      },
                      {
                        "control_type": "text",
                        "label": "Middle name",
                        "type": "string",
                        "name": "MiddleName"
                      },
                      {
                        "control_type": "text",
                        "label": "Last name",
                        "type": "string",
                        "name": "LastName"
                      },
                      {
                        "control_type": "text",
                        "label": "Title",
                        "type": "string",
                        "name": "Title"
                      },
                      {
                        "control_type": "text",
                        "label": "Company",
                        "type": "string",
                        "name": "Company"
                      },
                      {
                        "control_type": "number",
                        "label": "Order",
                        "parse_output": "float_conversion",
                        "type": "number",
                        "name": "Order"
                      }
                    ]
                  },
                  {
                    "control_type": "text",
                    "label": "Notes",
                    "type": "string",
                    "name": "Notes"
                  },
                  {
                    "control_type": "number",
                    "label": "Vendor type key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "VendorTypeKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Vendor type description",
                    "type": "string",
                    "name": "VendorTypeDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Vendor type is consultant",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Vendor type is consultant",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "VendorTypeIsConsultant"
                    },
                    "type": "boolean",
                    "name": "VendorTypeIsConsultant"
                  },
                  {
                    "control_type": "text",
                    "label": "Vendor type is credit card",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Vendor type is credit card",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "VendorTypeIsCreditCard"
                    },
                    "type": "boolean",
                    "name": "VendorTypeIsCreditCard"
                  },
                  {
                    "control_type": "text",
                    "label": "Vendor type notes",
                    "type": "string",
                    "name": "VendorTypeNotes"
                  },
                  {
                    "control_type": "text",
                    "label": "Last modified date",
                    "type": "string",
                    "name": "LastModifiedDate"
                  },
                  {
                    "control_type": "text",
                    "label": "CF MBE vendor",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "CF MBE vendor",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "CF_MBEVendor"
                    },
                    "type": "boolean",
                    "name": "CF_MBEVendor"
                  },
                  {
                    "control_type": "text",
                    "label": "CF WBE vendor",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "CF WBE vendor",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "CF_WBEVendor"
                    },
                    "type": "boolean",
                    "name": "CF_WBEVendor"
                  }
                ]
              }
            ],
            "label": "Content",
            "type": "object",
            "name": "Content"
          },
          {
            "control_type": "text",
            "label": "Usage key",
            "type": "string",
            "name": "UsageKey"
          }
        ]
      end,
    },

    list_pays_output: {
      fields: lambda do
        [
          {
            "control_type": "integer",
            "label": "Response code",
            "parse_output": "integer_conversion",
            "type": "integer",
            "name": "ResponseCode"
          },
          {
            "control_type": "text",
            "label": "Message",
            "type": "string",
            "name": "Message"
          },
          {
            "control_type": "array",
            "label": "Errors",
            "type": "array",
            "of": "object",
            "name": "Errors",
            "properties": [
              {
                "control_type": "number",
                "label": "Error ID",
                "parse_output": "integer_conversion",
                "type": "number",
                "name": "ErrorID"
              },
              {
                "control_type": "text",
                "label": "Error Message",
                "type": "string",
                "name": "ErrorMessage"
              }
            ]
          },
          {
            "control_type": "object",
            "label": "Content",
            "type": "object",
            "name": "Content",
            "properties": [
              {
                "control_type": "array",
                "label": "Pays",
                "type": "array",
                "of": "object",
                "name": "Pays",
                "properties": [
                  {
                    "control_type": "number",
                    "label": "Pay Key",
                    "parse_output": "integer_conversion",
                    "type": "number",
                    "name": "PayKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Description",
                    "type": "string",
                    "name": "Description"
                  },
                  {
                    "control_type": "text",
                    "label": "Status",
                    "type": "string",
                    "name": "Status"
                  },
                  {
                    "control_type": "text",
                    "label": "Notes",
                    "type": "string",
                    "name": "Notes"
                  }
                ]
              }
            ]
          },
          {
            "control_type": "text",
            "label": "Usage Key",
            "type": "string",
            "name": "UsageKey"
          }
        ]
      end
    },
    vendors_output: {
      fields: lambda do
        [
          {
            "control_type": "number",
            "label": "Response code",
            "parse_output": "float_conversion",
            "type": "number",
            "name": "ResponseCode"
          },
          {
            "control_type": "text",
            "label": "Message",
            "type": "string",
            "name": "Message"
          },
          {
            "properties": [
              {
                "name": "Vendors",
                "type": "array",
                "of": "object",
                "label": "Vendors",
                "properties": [
                  {
                    "control_type": "number",
                    "label": "Vendor key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "VendorKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Name",
                    "type": "string",
                    "name": "Name"
                  }
                ]
              }
            ],
            "label": "Content",
            "type": "object",
            "name": "Content"
          },
          {
            "control_type": "text",
            "label": "Usage key",
            "type": "string",
            "name": "UsageKey"
          }
        ]
      end,
    },
  },
  custom_action: true,

  custom_action_help: {
    learn_more_url: "https://help.deltek.com/Product/Ajera/api/index.html",

    learn_more_text: "Learm more",

    body: "<p>Build your own Deltek Ajera action with a HTTP request. <b>The request will be authorized with your Ajera connection.</b></p>"
  }
}
