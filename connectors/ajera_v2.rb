{
  title: 'Ajera Connector - V2',

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
              APIVersion: 2,
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

    list_projects: {
      title: "PROJECTS - List Projects",
      subtitle: "List Projects returns an array of Projects",

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
            type: "string",
            optional: true
          },
          {
            name: "FilterByLatestModifiedDate",
            label: "Latest Modfied Date",
            hint: "Filter By Latest Modified Date Eg. format 2015-03-11 16:22:54.229 GMT-0700",
            type: "string",
            optional: true
          },
        ]
      end,

      execute: lambda do |connection, input|
        post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
          payload(Method: "ListProjects",
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
        object_definitions[:projects_output]
      end
    },

    get_projects: {
      title: "PROJECTS - Get Projects",
      subtitle: "Get Projects takes one or more key values, and returns an array of matching Projects",

      input_fields: lambda do |object_definitions|
        [
          {
            name: "RequestedProjects",
            label: "Requested Projects",
            type: "array",
            of: "integer",
            optional: false
          },
        ]
      end,

      execute: lambda do |connection, input|
        post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
          payload(Method: "GetProjects",
            #SessionToken: connection['SessionToken'],
            MethodArguments:  {
              "RequestedProjects": input["RequestedProjects"] }
          )
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:projects_detail_output]
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

    post_invoices: {
      title: "INVOICES - Create Vendor Invoices",
      subtitle: "Create a new vendor invoice",

      input_fields: lambda do |object_definitions|
        [
          {
            name: "ShowTiming",
            label: "Show Timing",
            type: "boolean",
            control_type: "checkbox",
            convert_input: "boolean_conversion"
          },
          {
            name: "VendorInvoices",
            label: "Vendor Invoices",
            type: "array",
            of: "object",
            properties: [
              {
                name: "VendorKey",
                label: "Vendor Key",
                control_type: "integer", 
                type: "integer",
                convert_input: "integer_conversion"
              },
              {
                name: "Amount",
                label: "Amount",
                control_type: "number", 
                type: "number",
                convert_input: "float_conversion"
              },
              {
                name: "LineItems",
                label: "Line Items",
                type: "array",
                of: "object",
                properties: [
                  {
                    name: "AccountKey",
                    label: "Account Key",
                    control_type: "integer", 
                    type: "integer",
                    convert_input: "integer_conversion"
                  },
                  {
                    name: "DepartmentKey",
                    label: "Department Key",
                    control_type: "integer", 
                    type: "integer",
                    convert_input: "integer_conversion"
                  },
                  {
                    name: "CostAmount",
                    label: "Cost Amount",
                    control_type: "number", 
                    type: "number",
                    convert_input: "float_conversion"
                  },
                ]
              },
              
            ]
          }
        ]
      end,

      execute: lambda do |connection, input|
        post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
          payload(
            Method: "CreateVendorInvoices",
            #SessionToken: connection['SessionToken'],
            MethodArguments:  {
              "ShowTiming": input["ShowTiming"],
              "VendorInvoices": input["VendorInvoices"]
            }
          )
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:create_vendor_invoices_output]
      end
    },
    
    list_invoices: {
      title: "INVOICES - List Vendor Invoices",
      subtitle: "Create a new vendor invoice",

      input_fields: lambda do |object_definitions|
        [
          {
            name: "FilterByVendor",
            label: "Filter By Vendor",
            type: "array",
            of: "integer",
            control_type: "integer"
          },
          {
            name: "FilterByCompany",
            label: "Filter By Company",
            type: "integer",
            control_type: "integer",
            convert_input: "integer_conversion"
          },
          {
            name: "FilterByVendorType",
            label: "Filter By Vendor Type",
            type: "integer",
            control_type: "integer",
            convert_input: "integer_conversion"
          },
          {
            name: "FilterByPaid",
            label: "Filter By Paid",
            type: "boolean",
            control_type: "checkbox",
            convert_input: "boolean_conversion"
          },
          {
            name: "FilterByUnpaid",
            label: "Filter By Unpaid",
            type: "boolean",
            control_type: "checkbox",
            convert_input: "boolean_conversion"
          },
          {
            name: "FilterByVoided",
            label: "Filter By Voided",
            type: "boolean",
            control_type: "checkbox",
            convert_input: "boolean_conversion"
          },
          {
            name: "FilterByEarliestInvoiceDate",
            label: "Filter By Earliest Invoice Date",
            type: "date"
          },
          {
            name: "FilterByLatestInvoiceDate",
            label: "Filter By Latest Invoice Date",
            type: "date"
          },
          {
            name: "FilterByEarliestAccountingDate",
            label: "Filter By Earliest Accounting Date",
            type: "date"
          },
          {
            name: "FilterByLatestAccountingDate",
            label: "Filter By Latest Accounting Date",
            type: "date"
          },
          {
            name: "FilterByEarliestInvoiceDatetoPay",
            label: "Filter By Earliest Invoice Date to Pay",
            type: "date"
          },
          {
            name: "FilterByLatestDatetoPay",
            label: "Filter By Latest Date to Pay",
            type: "date"
          },
          {
            name: "FilterByGreaterThanAmount",
            label: "Filter By Greater Than Amount",
            type: "number",
            control_type: "number",
            convert_input: "float_conversion"
          },
          {
            name: "FilterByLessThanAmount",
            label: "Filter By Less Than Amount",
            type: "number",
            control_type: "number",
            convert_input: "float_conversion"
          },
          {
            name: "FilterByEqualToAmount",
            label: "Filter By Equal To Amount",
            type: "number",
            control_type: "number",
            convert_input: "float_conversion"
          }
        ]
      end,

      execute: lambda do |connection, input|
        post("https://ajera.com/#{connection['CustomerId']}/AjeraAPI.ashx?#{connection['ClientUrlKey']}").
          payload(
            Method: "ListVendorInvoices",
            #SessionToken: connection['SessionToken'],
            MethodArguments:  {
              "FilterByVendor": input["FilterByVendor"],
              "FilterByCompany": input["FilterByCompany"],
              "FilterByVendorType": input["FilterByVendorType"],
              "FilterByPaid": input["FilterByPaid"],
              "FilterByUnpaid": input["FilterByUnpaid"],
              "FilterByVoided": input["FilterByVoided"],
              "FilterByEarliestInvoiceDate": input["FilterByEarliestInvoiceDate"],
              "FilterByLatestInvoiceDate": input["FilterByLatestInvoiceDate"],
              "FilterByEarliestAccountingDate": input["FilterByEarliestAccountingDate"],
              "FilterByLatestAccountingDate": input["FilterByLatestAccountingDate"],
              "FilterByEarliestInvoiceDatetoPay": input["FilterByEarliestInvoiceDatetoPay"],
              "FilterByLatestDatetoPay": input["FilterByLatestDatetoPay"],
              "FilterByGreaterThanAmount": input["FilterByGreaterThanAmount"],
              "FilterByLessThanAmount": input["FilterByLessThanAmount"],
              "FilterByEqualToAmount": input["FilterByEqualToAmount"]
            }.compact
          )
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:list_vendor_invoices_output]
      end
    },

  },

  triggers: {

    new_updated_projects: {
      title: "New/Updated Projects",
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
          payload(Method: "ListProjects",
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
        object_definitions[:projects_output]
      end
    },

    new_updated_vendors: {
      title: "New/Updated Vendors",
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
          payload(Method: "ListVendors",
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
        object_definitions[:vendors_output]
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

    projects_output: {
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
                "name": "Projects",
                "type": "array",
                "of": "object",
                "label": "Projects",
                "properties": [
                  {
                    "control_type": "number",
                    "label": "Project key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ProjectKey"
                  },
                  {
                    "control_type": "text",
                    "label": "ID",
                    "type": "string",
                    "name": "ID"
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
      end,
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

    projects_detail_output:{
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
                "name": "Projects",
                "type": "array",
                "of": "object",
                "label": "Projects",
                "properties": [
                  {
                    "control_type": "number",
                    "label": "Project key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ProjectKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Last modified date",
                    "type": "string",
                    "name": "LastModifiedDate"
                  },
                  {
                    "control_type": "text",
                    "label": "ID",
                    "type": "string",
                    "name": "ID"
                  },
                  {
                    "control_type": "text",
                    "label": "Description",
                    "type": "string",
                    "name": "Description"
                  },
                  {
                    "control_type": "text",
                    "label": "Sync to CRM",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Sync to CRM",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "SyncToCRM"
                    },
                    "type": "boolean",
                    "name": "SyncToCRM"
                  },
                  {
                    "control_type": "text",
                    "label": "Create in CRM",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Create in CRM",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "CreateInCRM"
                    },
                    "type": "boolean",
                    "name": "CreateInCRM"
                  },
                  {
                    "control_type": "text",
                    "label": "CRM final sync",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "CRM final sync",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "CRMFinalSync"
                    },
                    "type": "boolean",
                    "name": "CRMFinalSync"
                  },
                  {
                    "control_type": "text",
                    "label": "Status",
                    "type": "string",
                    "name": "Status"
                  },
                  {
                    "control_type": "text",
                    "label": "Summarize billing group",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Summarize billing group",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "SummarizeBillingGroup"
                    },
                    "type": "boolean",
                    "name": "SummarizeBillingGroup"
                  },
                  {
                    "control_type": "text",
                    "label": "Billing description",
                    "type": "string",
                    "name": "BillingDescription"
                  },
                  {
                    "control_type": "number",
                    "label": "Company key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "CompanyKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Company description",
                    "type": "string",
                    "name": "CompanyDescription"
                  },
                  {
                    "control_type": "number",
                    "label": "Project type key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ProjectTypeKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Project type description",
                    "type": "string",
                    "name": "ProjectTypeDescription"
                  },
                  {
                    "control_type": "number",
                    "label": "Department key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "DepartmentKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Department description",
                    "type": "string",
                    "name": "DepartmentDescription"
                  },
                  {
                    "control_type": "number",
                    "label": "Budgeted overhead rate",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "BudgetedOverheadRate"
                  },
                  {
                    "properties": [
                      {
                        "control_type": "number",
                        "label": "Employee key",
                        "parse_output": "float_conversion",
                        "type": "number",
                        "name": "EmployeeKey"
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
                      }
                    ],
                    "label": "Project manager",
                    "type": "object",
                    "name": "ProjectManager"
                  },
                  {
                    "properties": [
                      {
                        "control_type": "number",
                        "label": "Employee key",
                        "parse_output": "float_conversion",
                        "type": "number",
                        "name": "EmployeeKey"
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
                      }
                    ],
                    "label": "Principal in charge",
                    "type": "object",
                    "name": "PrincipalInCharge"
                  },
                  {
                    "properties": [
                      {
                        "control_type": "number",
                        "label": "Employee key",
                        "parse_output": "float_conversion",
                        "type": "number",
                        "name": "EmployeeKey"
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
                      }
                    ],
                    "label": "Marketing contact",
                    "type": "object",
                    "name": "MarketingContact"
                  },
                  {
                    "control_type": "text",
                    "label": "Location",
                    "type": "string",
                    "name": "Location"
                  },
                  {
                    "control_type": "text",
                    "label": "Wage table key",
                    "type": "string",
                    "name": "WageTableKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Wage table description",
                    "type": "string",
                    "name": "WageTableDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Is certified",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Is certified",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "IsCertified"
                    },
                    "type": "boolean",
                    "name": "IsCertified"
                  },
                  {
                    "control_type": "text",
                    "label": "Restrict time entry to resources only",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Restrict time entry to resources only",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "RestrictTimeEntryToResourcesOnly"
                    },
                    "type": "boolean",
                    "name": "RestrictTimeEntryToResourcesOnly"
                  },
                  {
                    "control_type": "text",
                    "label": "Tax state",
                    "type": "string",
                    "name": "TaxState"
                  },
                  {
                    "control_type": "text",
                    "label": "Tax local key",
                    "type": "string",
                    "name": "TaxLocalKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Tax local description",
                    "type": "string",
                    "name": "TaxLocalDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Estimated start date",
                    "type": "string",
                    "name": "EstimatedStartDate"
                  },
                  {
                    "control_type": "text",
                    "label": "Estimated completion date",
                    "type": "string",
                    "name": "EstimatedCompletionDate"
                  },
                  {
                    "control_type": "text",
                    "label": "Actual start date",
                    "type": "string",
                    "name": "ActualStartDate"
                  },
                  {
                    "control_type": "text",
                    "label": "Actual completion date",
                    "type": "string",
                    "name": "ActualCompletionDate"
                  },
                  {
                    "control_type": "text",
                    "label": "Apply sales tax",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Apply sales tax",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "ApplySalesTax"
                    },
                    "type": "boolean",
                    "name": "ApplySalesTax"
                  },
                  {
                    "control_type": "text",
                    "label": "Sales tax code",
                    "type": "string",
                    "name": "SalesTaxCode"
                  },
                  {
                    "control_type": "number",
                    "label": "Sales tax rate",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "SalesTaxRate"
                  },
                  {
                    "control_type": "text",
                    "label": "Require timesheet notes",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Require timesheet notes",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "RequireTimesheetNotes"
                    },
                    "type": "boolean",
                    "name": "RequireTimesheetNotes"
                  },
                  {
                    "control_type": "text",
                    "label": "Notes",
                    "type": "string",
                    "name": "Notes"
                  },
                  {
                    "control_type": "number",
                    "label": "Hours cost budget",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "HoursCostBudget"
                  },
                  {
                    "control_type": "number",
                    "label": "Labor cost budget",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "LaborCostBudget"
                  },
                  {
                    "control_type": "number",
                    "label": "Expense cost budget",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ExpenseCostBudget"
                  },
                  {
                    "control_type": "number",
                    "label": "Consultant cost budget",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ConsultantCostBudget"
                  },
                  {
                    "control_type": "number",
                    "label": "Percent distribution",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "PercentDistribution"
                  },
                  {
                    "control_type": "text",
                    "label": "Is final budget",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Is final budget",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "IsFinalBudget"
                    },
                    "type": "boolean",
                    "name": "IsFinalBudget"
                  },
                  {
                    "control_type": "text",
                    "label": "Billing type",
                    "type": "string",
                    "name": "BillingType"
                  },
                  {
                    "control_type": "number",
                    "label": "Rate table key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "RateTableKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Rate table description",
                    "type": "string",
                    "name": "RateTableDescription"
                  },
                  {
                    "control_type": "number",
                    "label": "Total contract amount",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "TotalContractAmount"
                  },
                  {
                    "control_type": "number",
                    "label": "Labor contract amount",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "LaborContractAmount"
                  },
                  {
                    "control_type": "number",
                    "label": "Expense contract amount",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ExpenseContractAmount"
                  },
                  {
                    "control_type": "number",
                    "label": "Consultant contract amount",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ConsultantContractAmount"
                  },
                  {
                    "control_type": "text",
                    "label": "Bill labor as TE",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Bill labor as TE",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "BillLaborAsTE"
                    },
                    "type": "boolean",
                    "name": "BillLaborAsTE"
                  },
                  {
                    "control_type": "text",
                    "label": "Bill expense as TE",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Bill expense as TE",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "BillExpenseAsTE"
                    },
                    "type": "boolean",
                    "name": "BillExpenseAsTE"
                  },
                  {
                    "control_type": "text",
                    "label": "Bill consultant as TE",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Bill consultant as TE",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "BillConsultantAsTE"
                    },
                    "type": "boolean",
                    "name": "BillConsultantAsTE"
                  },
                  {
                    "control_type": "text",
                    "label": "Lock fee",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Lock fee",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "LockFee"
                    },
                    "type": "boolean",
                    "name": "LockFee"
                  },
                  {
                    "control_type": "number",
                    "label": "Construction cost",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ConstructionCost"
                  },
                  {
                    "control_type": "number",
                    "label": "Percent of construction cost",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "PercentOfConstructionCost"
                  },
                  {
                    "control_type": "text",
                    "label": "Labor entry",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Labor entry",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "LaborEntry"
                    },
                    "type": "boolean",
                    "name": "LaborEntry"
                  },
                  {
                    "control_type": "text",
                    "label": "Expense consultant entry",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "Expense consultant entry",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "ExpenseConsultantEntry"
                    },
                    "type": "boolean",
                    "name": "ExpenseConsultantEntry"
                  },
                  {
                    "properties": [
                      {
                        "control_type": "text",
                        "label": "Value",
                        "type": "string",
                        "name": "Value"
                      },
                      {
                        "control_type": "text",
                        "label": "Allow edit",
                        "render_input": {},
                        "parse_output": {},
                        "toggle_hint": "Select from option list",
                        "toggle_field": {
                          "label": "Allow edit",
                          "control_type": "text",
                          "toggle_hint": "Use custom value",
                          "type": "boolean",
                          "name": "AllowEdit"
                        },
                        "type": "boolean",
                        "name": "AllowEdit"
                      }
                    ],
                    "label": "CF interior design PM",
                    "type": "object",
                    "name": "CF_InteriorDesignPM"
                  },
                  {
                    "properties": [
                      {
                        "control_type": "text",
                        "label": "Value",
                        "type": "string",
                        "name": "Value"
                      },
                      {
                        "control_type": "text",
                        "label": "Allow edit",
                        "render_input": {},
                        "parse_output": {},
                        "toggle_hint": "Select from option list",
                        "toggle_field": {
                          "label": "Allow edit",
                          "control_type": "text",
                          "toggle_hint": "Use custom value",
                          "type": "boolean",
                          "name": "AllowEdit"
                        },
                        "type": "boolean",
                        "name": "AllowEdit"
                      }
                    ],
                    "label": "CF marketing lead",
                    "type": "object",
                    "name": "CF_MarketingLead"
                  },
                  {
                    "properties": [
                      {
                        "control_type": "text",
                        "label": "Value",
                        "type": "string",
                        "name": "Value"
                      },
                      {
                        "control_type": "text",
                        "label": "Allow edit",
                        "render_input": {},
                        "parse_output": {},
                        "toggle_hint": "Select from option list",
                        "toggle_field": {
                          "label": "Allow edit",
                          "control_type": "text",
                          "toggle_hint": "Use custom value",
                          "type": "boolean",
                          "name": "AllowEdit"
                        },
                        "type": "boolean",
                        "name": "AllowEdit"
                      }
                    ],
                    "label": "CF co architect PM",
                    "type": "object",
                    "name": "CF_CoArchitectPM"
                  },
                  {
                    "properties": [
                      {
                        "control_type": "text",
                        "label": "Value",
                        "type": "string",
                        "name": "Value"
                      },
                      {
                        "control_type": "text",
                        "label": "Allow edit",
                        "render_input": {},
                        "parse_output": {},
                        "toggle_hint": "Select from option list",
                        "toggle_field": {
                          "label": "Allow edit",
                          "control_type": "text",
                          "toggle_hint": "Use custom value",
                          "type": "boolean",
                          "name": "AllowEdit"
                        },
                        "type": "boolean",
                        "name": "AllowEdit"
                      }
                    ],
                    "label": "CF construction type",
                    "type": "object",
                    "name": "CF_ConstructionType"
                  },
                  {
                    "properties": [
                      {
                        "control_type": "text",
                        "label": "Value",
                        "type": "string",
                        "name": "Value"
                      },
                      {
                        "control_type": "text",
                        "label": "Allow edit",
                        "render_input": {},
                        "parse_output": {},
                        "toggle_hint": "Select from option list",
                        "toggle_field": {
                          "label": "Allow edit",
                          "control_type": "text",
                          "toggle_hint": "Use custom value",
                          "type": "boolean",
                          "name": "AllowEdit"
                        },
                        "type": "boolean",
                        "name": "AllowEdit"
                      }
                    ],
                    "label": "CF delivery method",
                    "type": "object",
                    "name": "CF_DeliveryMethod"
                  },
                  {
                    "properties": [
                      {
                        "control_type": "text",
                        "label": "Value",
                        "type": "string",
                        "name": "Value"
                      },
                      {
                        "control_type": "text",
                        "label": "Allow edit",
                        "render_input": {},
                        "parse_output": {},
                        "toggle_hint": "Select from option list",
                        "toggle_field": {
                          "label": "Allow edit",
                          "control_type": "text",
                          "toggle_hint": "Use custom value",
                          "type": "boolean",
                          "name": "AllowEdit"
                        },
                        "type": "boolean",
                        "name": "AllowEdit"
                      }
                    ],
                    "label": "CF construction partner",
                    "type": "object",
                    "name": "CF_ConstructionPartner"
                  },
                  {
                    "control_type": "number",
                    "label": "CF estimated construction cost",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "CF_EstimatedConstructionCost"
                  },
                  {
                    "control_type": "number",
                    "label": "CF construction cost",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "CF_ConstructionCost"
                  },
                  {
                    "control_type": "number",
                    "label": "CF estimated gross SF",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "CF_EstimatedGrossSF"
                  },
                  {
                    "control_type": "number",
                    "label": "CF sq ft",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "CF_SqFt"
                  },
                  {
                    "properties": [
                      {
                        "control_type": "text",
                        "label": "Value",
                        "type": "string",
                        "name": "Value"
                      },
                      {
                        "control_type": "text",
                        "label": "Allow edit",
                        "render_input": {},
                        "parse_output": {},
                        "toggle_hint": "Select from option list",
                        "toggle_field": {
                          "label": "Allow edit",
                          "control_type": "text",
                          "toggle_hint": "Use custom value",
                          "type": "boolean",
                          "name": "AllowEdit"
                        },
                        "type": "boolean",
                        "name": "AllowEdit"
                      }
                    ],
                    "label": "CF project state",
                    "type": "object",
                    "name": "CF_ProjectState"
                  },
                  {
                    "properties": [
                      {
                        "control_type": "text",
                        "label": "Value",
                        "type": "string",
                        "name": "Value"
                      },
                      {
                        "control_type": "text",
                        "label": "Allow edit",
                        "render_input": {},
                        "parse_output": {},
                        "toggle_hint": "Select from option list",
                        "toggle_field": {
                          "label": "Allow edit",
                          "control_type": "text",
                          "toggle_hint": "Use custom value",
                          "type": "boolean",
                          "name": "AllowEdit"
                        },
                        "type": "boolean",
                        "name": "AllowEdit"
                      },
                      {
                        "name": "Values",
                        "type": "array",
                        "of": "string",
                        "control_type": "text",
                        "label": "Values"
                      }
                    ],
                    "label": "CF closeout year",
                    "type": "object",
                    "name": "CF_CloseoutYear"
                  },
                  {
                    "control_type": "text",
                    "label": "CF notes",
                    "type": "string",
                    "name": "CF_Notes"
                  },
                  {
                    "control_type": "text",
                    "label": "CF architecture",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "CF architecture",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "CF_Architecture"
                    },
                    "type": "boolean",
                    "name": "CF_Architecture"
                  },
                  {
                    "control_type": "text",
                    "label": "CF construction",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "CF construction",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "CF_Construction"
                    },
                    "type": "boolean",
                    "name": "CF_Construction"
                  },
                  {
                    "control_type": "text",
                    "label": "CF FFE procurement",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "CF FFE procurement",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "CF_FFEProcurement"
                    },
                    "type": "boolean",
                    "name": "CF_FFEProcurement"
                  },
                  {
                    "control_type": "text",
                    "label": "CF graphic design",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "CF graphic design",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "CF_GraphicDesign"
                    },
                    "type": "boolean",
                    "name": "CF_GraphicDesign"
                  },
                  {
                    "control_type": "text",
                    "label": "CF interior design",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "CF interior design",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "CF_InteriorDesign"
                    },
                    "type": "boolean",
                    "name": "CF_InteriorDesign"
                  },
                  {
                    "control_type": "text",
                    "label": "CF landscape architecture",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "CF landscape architecture",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "CF_LandscapeArchitecture"
                    },
                    "type": "boolean",
                    "name": "CF_LandscapeArchitecture"
                  },
                  {
                    "control_type": "text",
                    "label": "CF master planning",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "CF master planning",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "CF_MasterPlanning"
                    },
                    "type": "boolean",
                    "name": "CF_MasterPlanning"
                  },
                  {
                    "control_type": "text",
                    "label": "CF development consulting",
                    "render_input": {},
                    "parse_output": {},
                    "toggle_hint": "Select from option list",
                    "toggle_field": {
                      "label": "CF development consulting",
                      "control_type": "text",
                      "toggle_hint": "Use custom value",
                      "type": "boolean",
                      "name": "CF_DevelopmentConsulting"
                    },
                    "type": "boolean",
                    "name": "CF_DevelopmentConsulting"
                  },
                  {
                    "control_type": "text",
                    "label": "CF other",
                    "type": "string",
                    "name": "CF_Other"
                  },
                  {
                    "name": "InvoiceGroups",
                    "type": "array",
                    "of": "object",
                    "label": "Invoice groups",
                    "properties": [
                      {
                        "control_type": "number",
                        "label": "Invoice group key",
                        "parse_output": "float_conversion",
                        "type": "number",
                        "name": "InvoiceGroupKey"
                      },
                      {
                        "control_type": "text",
                        "label": "Description",
                        "type": "string",
                        "name": "Description"
                      },
                      {
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
                        ],
                        "label": "Client",
                        "type": "object",
                        "name": "Client"
                      },
                      {
                        "control_type": "number",
                        "label": "Invoice format key",
                        "parse_output": "float_conversion",
                        "type": "number",
                        "name": "InvoiceFormatKey"
                      },
                      {
                        "control_type": "text",
                        "label": "Invoice format description",
                        "type": "string",
                        "name": "InvoiceFormatDescription"
                      },
                      {
                        "control_type": "number",
                        "label": "Email invoice template key",
                        "parse_output": "float_conversion",
                        "type": "number",
                        "name": "EmailInvoiceTemplateKey"
                      },
                      {
                        "control_type": "text",
                        "label": "Email invoice template description",
                        "type": "string",
                        "name": "EmailInvoiceTemplateDescription"
                      },
                      {
                        "control_type": "text",
                        "label": "Email client statement template key",
                        "type": "string",
                        "name": "EmailClientStatementTemplateKey"
                      },
                      {
                        "control_type": "text",
                        "label": "Email client statement template description",
                        "type": "string",
                        "name": "EmailClientStatementTemplateDescription"
                      },
                      {
                        "control_type": "text",
                        "label": "Print backup",
                        "render_input": {},
                        "parse_output": {},
                        "toggle_hint": "Select from option list",
                        "toggle_field": {
                          "label": "Print backup",
                          "control_type": "text",
                          "toggle_hint": "Use custom value",
                          "type": "boolean",
                          "name": "PrintBackup"
                        },
                        "type": "boolean",
                        "name": "PrintBackup"
                      },
                      {
                        "control_type": "text",
                        "label": "Email include backup",
                        "render_input": {},
                        "parse_output": {},
                        "toggle_hint": "Select from option list",
                        "toggle_field": {
                          "label": "Email include backup",
                          "control_type": "text",
                          "toggle_hint": "Use custom value",
                          "type": "boolean",
                          "name": "EmailIncludeBackup"
                        },
                        "type": "boolean",
                        "name": "EmailIncludeBackup"
                      },
                      {
                        "control_type": "text",
                        "label": "Invoice header text",
                        "type": "string",
                        "name": "InvoiceHeaderText"
                      },
                      {
                        "control_type": "text",
                        "label": "Invoice footer text",
                        "type": "string",
                        "name": "InvoiceFooterText"
                      },
                      {
                        "control_type": "text",
                        "label": "Invoice scope",
                        "type": "string",
                        "name": "InvoiceScope"
                      },
                      {
                        "control_type": "text",
                        "label": "Notes",
                        "type": "string",
                        "name": "Notes"
                      },
                      {
                        "name": "Phases",
                        "type": "array",
                        "of": "object",
                        "label": "Phases",
                        "properties": [
                          {
                            "control_type": "number",
                            "label": "Phase key",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "PhaseKey"
                          },
                          {
                            "control_type": "text",
                            "label": "Last modified date",
                            "type": "string",
                            "name": "LastModifiedDate"
                          },
                          {
                            "control_type": "text",
                            "label": "ID",
                            "type": "string",
                            "name": "ID"
                          },
                          {
                            "control_type": "text",
                            "label": "Description",
                            "type": "string",
                            "name": "Description"
                          },
                          {
                            "control_type": "text",
                            "label": "Sync to CRM",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Sync to CRM",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "SyncToCRM"
                            },
                            "type": "boolean",
                            "name": "SyncToCRM"
                          },
                          {
                            "control_type": "text",
                            "label": "Create in CRM",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Create in CRM",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "CreateInCRM"
                            },
                            "type": "boolean",
                            "name": "CreateInCRM"
                          },
                          {
                            "control_type": "text",
                            "label": "CRM final sync",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "CRM final sync",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "CRMFinalSync"
                            },
                            "type": "boolean",
                            "name": "CRMFinalSync"
                          },
                          {
                            "control_type": "text",
                            "label": "Status",
                            "type": "string",
                            "name": "Status"
                          },
                          {
                            "control_type": "text",
                            "label": "Is billing group",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Is billing group",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "IsBillingGroup"
                            },
                            "type": "boolean",
                            "name": "IsBillingGroup"
                          },
                          {
                            "control_type": "text",
                            "label": "Summarize billing group",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Summarize billing group",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "SummarizeBillingGroup"
                            },
                            "type": "boolean",
                            "name": "SummarizeBillingGroup"
                          },
                          {
                            "control_type": "number",
                            "label": "Project type key",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "ProjectTypeKey"
                          },
                          {
                            "control_type": "text",
                            "label": "Project type description",
                            "type": "string",
                            "name": "ProjectTypeDescription"
                          },
                          {
                            "control_type": "number",
                            "label": "Department key",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "DepartmentKey"
                          },
                          {
                            "control_type": "text",
                            "label": "Department description",
                            "type": "string",
                            "name": "DepartmentDescription"
                          },
                          {
                            "control_type": "number",
                            "label": "Budgeted overhead rate",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "BudgetedOverheadRate"
                          },
                          {
                            "properties": [
                              {
                                "control_type": "number",
                                "label": "Employee key",
                                "parse_output": "float_conversion",
                                "type": "number",
                                "name": "EmployeeKey"
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
                              }
                            ],
                            "label": "Project manager",
                            "type": "object",
                            "name": "ProjectManager"
                          },
                          {
                            "properties": [
                              {
                                "control_type": "number",
                                "label": "Employee key",
                                "parse_output": "float_conversion",
                                "type": "number",
                                "name": "EmployeeKey"
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
                              }
                            ],
                            "label": "Principal in charge",
                            "type": "object",
                            "name": "PrincipalInCharge"
                          },
                          {
                            "properties": [
                              {
                                "control_type": "number",
                                "label": "Employee key",
                                "parse_output": "float_conversion",
                                "type": "number",
                                "name": "EmployeeKey"
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
                              }
                            ],
                            "label": "Marketing contact",
                            "type": "object",
                            "name": "MarketingContact"
                          },
                          {
                            "control_type": "text",
                            "label": "Wage table key",
                            "type": "string",
                            "name": "WageTableKey"
                          },
                          {
                            "control_type": "text",
                            "label": "Wage table description",
                            "type": "string",
                            "name": "WageTableDescription"
                          },
                          {
                            "control_type": "text",
                            "label": "Is certified",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Is certified",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "IsCertified"
                            },
                            "type": "boolean",
                            "name": "IsCertified"
                          },
                          {
                            "control_type": "text",
                            "label": "Restrict time entry to resources only",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Restrict time entry to resources only",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "RestrictTimeEntryToResourcesOnly"
                            },
                            "type": "boolean",
                            "name": "RestrictTimeEntryToResourcesOnly"
                          },
                          {
                            "control_type": "text",
                            "label": "Tax state",
                            "type": "string",
                            "name": "TaxState"
                          },
                          {
                            "control_type": "text",
                            "label": "Tax local key",
                            "type": "string",
                            "name": "TaxLocalKey"
                          },
                          {
                            "control_type": "text",
                            "label": "Tax local description",
                            "type": "string",
                            "name": "TaxLocalDescription"
                          },
                          {
                            "control_type": "text",
                            "label": "Estimated start date",
                            "type": "string",
                            "name": "EstimatedStartDate"
                          },
                          {
                            "control_type": "text",
                            "label": "Estimated completion date",
                            "type": "string",
                            "name": "EstimatedCompletionDate"
                          },
                          {
                            "control_type": "text",
                            "label": "Actual start date",
                            "type": "string",
                            "name": "ActualStartDate"
                          },
                          {
                            "control_type": "text",
                            "label": "Actual completion date",
                            "type": "string",
                            "name": "ActualCompletionDate"
                          },
                          {
                            "control_type": "text",
                            "label": "Apply sales tax",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Apply sales tax",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "ApplySalesTax"
                            },
                            "type": "boolean",
                            "name": "ApplySalesTax"
                          },
                          {
                            "control_type": "text",
                            "label": "Sales tax code",
                            "type": "string",
                            "name": "SalesTaxCode"
                          },
                          {
                            "control_type": "number",
                            "label": "Sales tax rate",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "SalesTaxRate"
                          },
                          {
                            "control_type": "text",
                            "label": "Require timesheet notes",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Require timesheet notes",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "RequireTimesheetNotes"
                            },
                            "type": "boolean",
                            "name": "RequireTimesheetNotes"
                          },
                          {
                            "control_type": "text",
                            "label": "Notes",
                            "type": "string",
                            "name": "Notes"
                          },
                          {
                            "control_type": "number",
                            "label": "Hours cost budget",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "HoursCostBudget"
                          },
                          {
                            "control_type": "number",
                            "label": "Labor cost budget",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "LaborCostBudget"
                          },
                          {
                            "control_type": "number",
                            "label": "Expense cost budget",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "ExpenseCostBudget"
                          },
                          {
                            "control_type": "number",
                            "label": "Consultant cost budget",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "ConsultantCostBudget"
                          },
                          {
                            "control_type": "number",
                            "label": "Percent distribution",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "PercentDistribution"
                          },
                          {
                            "control_type": "text",
                            "label": "Is final budget",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Is final budget",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "IsFinalBudget"
                            },
                            "type": "boolean",
                            "name": "IsFinalBudget"
                          },
                          {
                            "control_type": "text",
                            "label": "Billing type",
                            "type": "string",
                            "name": "BillingType"
                          },
                          {
                            "control_type": "number",
                            "label": "Rate table key",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "RateTableKey"
                          },
                          {
                            "control_type": "text",
                            "label": "Rate table description",
                            "type": "string",
                            "name": "RateTableDescription"
                          },
                          {
                            "control_type": "number",
                            "label": "Total contract amount",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "TotalContractAmount"
                          },
                          {
                            "control_type": "number",
                            "label": "Labor contract amount",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "LaborContractAmount"
                          },
                          {
                            "control_type": "number",
                            "label": "Expense contract amount",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "ExpenseContractAmount"
                          },
                          {
                            "control_type": "number",
                            "label": "Consultant contract amount",
                            "parse_output": "float_conversion",
                            "type": "number",
                            "name": "ConsultantContractAmount"
                          },
                          {
                            "control_type": "text",
                            "label": "Bill labor as TE",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Bill labor as TE",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "BillLaborAsTE"
                            },
                            "type": "boolean",
                            "name": "BillLaborAsTE"
                          },
                          {
                            "control_type": "text",
                            "label": "Bill expense as TE",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Bill expense as TE",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "BillExpenseAsTE"
                            },
                            "type": "boolean",
                            "name": "BillExpenseAsTE"
                          },
                          {
                            "control_type": "text",
                            "label": "Bill consultant as TE",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Bill consultant as TE",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "BillConsultantAsTE"
                            },
                            "type": "boolean",
                            "name": "BillConsultantAsTE"
                          },
                          {
                            "control_type": "text",
                            "label": "Lock fee",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Lock fee",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "LockFee"
                            },
                            "type": "boolean",
                            "name": "LockFee"
                          },
                          {
                            "control_type": "text",
                            "label": "Billing description",
                            "type": "string",
                            "name": "BillingDescription"
                          },
                          {
                            "control_type": "text",
                            "label": "Phase invoice text",
                            "type": "string",
                            "name": "PhaseInvoiceText"
                          },
                          {
                            "control_type": "text",
                            "label": "Labor invoice text",
                            "type": "string",
                            "name": "LaborInvoiceText"
                          },
                          {
                            "control_type": "text",
                            "label": "Expense invoice text",
                            "type": "string",
                            "name": "ExpenseInvoiceText"
                          },
                          {
                            "control_type": "text",
                            "label": "Consultant invoice text",
                            "type": "string",
                            "name": "ConsultantInvoiceText"
                          },
                          {
                            "control_type": "text",
                            "label": "Labor entry",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Labor entry",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "LaborEntry"
                            },
                            "type": "boolean",
                            "name": "LaborEntry"
                          },
                          {
                            "control_type": "text",
                            "label": "Expense consultant entry",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "Expense consultant entry",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "ExpenseConsultantEntry"
                            },
                            "type": "boolean",
                            "name": "ExpenseConsultantEntry"
                          },
                          {
                            "properties": [
                              {
                                "control_type": "text",
                                "label": "Value",
                                "type": "string",
                                "name": "Value"
                              },
                              {
                                "control_type": "text",
                                "label": "Allow edit",
                                "render_input": {},
                                "parse_output": {},
                                "toggle_hint": "Select from option list",
                                "toggle_field": {
                                  "label": "Allow edit",
                                  "control_type": "text",
                                  "toggle_hint": "Use custom value",
                                  "type": "boolean",
                                  "name": "AllowEdit"
                                },
                                "type": "boolean",
                                "name": "AllowEdit"
                              }
                            ],
                            "label": "CF interior design PM",
                            "type": "object",
                            "name": "CF_InteriorDesignPM"
                          },
                          {
                            "properties": [
                              {
                                "control_type": "text",
                                "label": "Value",
                                "type": "string",
                                "name": "Value"
                              },
                              {
                                "control_type": "text",
                                "label": "Allow edit",
                                "render_input": {},
                                "parse_output": {},
                                "toggle_hint": "Select from option list",
                                "toggle_field": {
                                  "label": "Allow edit",
                                  "control_type": "text",
                                  "toggle_hint": "Use custom value",
                                  "type": "boolean",
                                  "name": "AllowEdit"
                                },
                                "type": "boolean",
                                "name": "AllowEdit"
                              }
                            ],
                            "label": "CF marketing lead",
                            "type": "object",
                            "name": "CF_MarketingLead"
                          },
                          {
                            "properties": [
                              {
                                "control_type": "text",
                                "label": "Value",
                                "type": "string",
                                "name": "Value"
                              },
                              {
                                "control_type": "text",
                                "label": "Allow edit",
                                "render_input": {},
                                "parse_output": {},
                                "toggle_hint": "Select from option list",
                                "toggle_field": {
                                  "label": "Allow edit",
                                  "control_type": "text",
                                  "toggle_hint": "Use custom value",
                                  "type": "boolean",
                                  "name": "AllowEdit"
                                },
                                "type": "boolean",
                                "name": "AllowEdit"
                              }
                            ],
                            "label": "CF co architect PM",
                            "type": "object",
                            "name": "CF_CoArchitectPM"
                          },
                          {
                            "properties": [
                              {
                                "control_type": "text",
                                "label": "Value",
                                "type": "string",
                                "name": "Value"
                              },
                              {
                                "control_type": "text",
                                "label": "Allow edit",
                                "render_input": {},
                                "parse_output": {},
                                "toggle_hint": "Select from option list",
                                "toggle_field": {
                                  "label": "Allow edit",
                                  "control_type": "text",
                                  "toggle_hint": "Use custom value",
                                  "type": "boolean",
                                  "name": "AllowEdit"
                                },
                                "type": "boolean",
                                "name": "AllowEdit"
                              }
                            ],
                            "label": "CF construction type",
                            "type": "object",
                            "name": "CF_ConstructionType"
                          },
                          {
                            "properties": [
                              {
                                "control_type": "text",
                                "label": "Value",
                                "type": "string",
                                "name": "Value"
                              },
                              {
                                "control_type": "text",
                                "label": "Allow edit",
                                "render_input": {},
                                "parse_output": {},
                                "toggle_hint": "Select from option list",
                                "toggle_field": {
                                  "label": "Allow edit",
                                  "control_type": "text",
                                  "toggle_hint": "Use custom value",
                                  "type": "boolean",
                                  "name": "AllowEdit"
                                },
                                "type": "boolean",
                                "name": "AllowEdit"
                              }
                            ],
                            "label": "CF delivery method",
                            "type": "object",
                            "name": "CF_DeliveryMethod"
                          },
                          {
                            "properties": [
                              {
                                "control_type": "text",
                                "label": "Value",
                                "type": "string",
                                "name": "Value"
                              },
                              {
                                "control_type": "text",
                                "label": "Allow edit",
                                "render_input": {},
                                "parse_output": {},
                                "toggle_hint": "Select from option list",
                                "toggle_field": {
                                  "label": "Allow edit",
                                  "control_type": "text",
                                  "toggle_hint": "Use custom value",
                                  "type": "boolean",
                                  "name": "AllowEdit"
                                },
                                "type": "boolean",
                                "name": "AllowEdit"
                              }
                            ],
                            "label": "CF construction partner",
                            "type": "object",
                            "name": "CF_ConstructionPartner"
                          },
                          {
                            "control_type": "text",
                            "label": "CF estimated construction cost",
                            "type": "string",
                            "name": "CF_EstimatedConstructionCost"
                          },
                          {
                            "control_type": "text",
                            "label": "CF construction cost",
                            "type": "string",
                            "name": "CF_ConstructionCost"
                          },
                          {
                            "control_type": "text",
                            "label": "CF estimated gross SF",
                            "type": "string",
                            "name": "CF_EstimatedGrossSF"
                          },
                          {
                            "control_type": "text",
                            "label": "CF sq ft",
                            "type": "string",
                            "name": "CF_SqFt"
                          },
                          {
                            "properties": [
                              {
                                "control_type": "text",
                                "label": "Value",
                                "type": "string",
                                "name": "Value"
                              },
                              {
                                "control_type": "text",
                                "label": "Allow edit",
                                "render_input": {},
                                "parse_output": {},
                                "toggle_hint": "Select from option list",
                                "toggle_field": {
                                  "label": "Allow edit",
                                  "control_type": "text",
                                  "toggle_hint": "Use custom value",
                                  "type": "boolean",
                                  "name": "AllowEdit"
                                },
                                "type": "boolean",
                                "name": "AllowEdit"
                              }
                            ],
                            "label": "CF project state",
                            "type": "object",
                            "name": "CF_ProjectState"
                          },
                          {
                            "properties": [
                              {
                                "control_type": "text",
                                "label": "Value",
                                "type": "string",
                                "name": "Value"
                              },
                              {
                                "control_type": "text",
                                "label": "Allow edit",
                                "render_input": {},
                                "parse_output": {},
                                "toggle_hint": "Select from option list",
                                "toggle_field": {
                                  "label": "Allow edit",
                                  "control_type": "text",
                                  "toggle_hint": "Use custom value",
                                  "type": "boolean",
                                  "name": "AllowEdit"
                                },
                                "type": "boolean",
                                "name": "AllowEdit"
                              },
                              {
                                "name": "Values",
                                "type": "array",
                                "of": "string",
                                "control_type": "text",
                                "label": "Values"
                              }
                            ],
                            "label": "CF closeout year",
                            "type": "object",
                            "name": "CF_CloseoutYear"
                          },
                          {
                            "control_type": "text",
                            "label": "CF notes",
                            "type": "string",
                            "name": "CF_Notes"
                          },
                          {
                            "control_type": "text",
                            "label": "CF architecture",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "CF architecture",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "CF_Architecture"
                            },
                            "type": "boolean",
                            "name": "CF_Architecture"
                          },
                          {
                            "control_type": "text",
                            "label": "CF construction",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "CF construction",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "CF_Construction"
                            },
                            "type": "boolean",
                            "name": "CF_Construction"
                          },
                          {
                            "control_type": "text",
                            "label": "CF FFE procurement",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "CF FFE procurement",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "CF_FFEProcurement"
                            },
                            "type": "boolean",
                            "name": "CF_FFEProcurement"
                          },
                          {
                            "control_type": "text",
                            "label": "CF graphic design",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "CF graphic design",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "CF_GraphicDesign"
                            },
                            "type": "boolean",
                            "name": "CF_GraphicDesign"
                          },
                          {
                            "control_type": "text",
                            "label": "CF interior design",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "CF interior design",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "CF_InteriorDesign"
                            },
                            "type": "boolean",
                            "name": "CF_InteriorDesign"
                          },
                          {
                            "control_type": "text",
                            "label": "CF landscape architecture",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "CF landscape architecture",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "CF_LandscapeArchitecture"
                            },
                            "type": "boolean",
                            "name": "CF_LandscapeArchitecture"
                          },
                          {
                            "control_type": "text",
                            "label": "CF master planning",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "CF master planning",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "CF_MasterPlanning"
                            },
                            "type": "boolean",
                            "name": "CF_MasterPlanning"
                          },
                          {
                            "control_type": "text",
                            "label": "CF development consulting",
                            "render_input": {},
                            "parse_output": {},
                            "toggle_hint": "Select from option list",
                            "toggle_field": {
                              "label": "CF development consulting",
                              "control_type": "text",
                              "toggle_hint": "Use custom value",
                              "type": "boolean",
                              "name": "CF_DevelopmentConsulting"
                            },
                            "type": "boolean",
                            "name": "CF_DevelopmentConsulting"
                          },
                          {
                            "control_type": "text",
                            "label": "CF other",
                            "type": "string",
                            "name": "CF_Other"
                          }
                        ]
                      }
                    ]
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
    create_vendor_invoices_output:{
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
            "control_type": "array",
            "label": "Warnings",
            "type": "array",
            "of": "string",
            "name": "Warnings"
          },
          {
            "control_type": "array",
            "label": "Content",
            "type": "array",
            "of": "object",
            "name": "Content",
            "properties": [
              {
                "name": "VendorInvoices",
                "type": "array",
                "of": "object",
                "label": "Vendor Invoices",
                "properties": [
                  {
                    "control_type": "number",
                    "label": "Vendor invoice key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "VendorInvoiceKey"
                  },
                  {
                    "control_type": "number",
                    "label": "Vendor key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "VendorKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Vendor description",
                    "type": "string",
                    "name": "VendorDescription"
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
                    "control_type": "number",
                    "label": "Company key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "CompanyKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Company description",
                    "type": "string",
                    "name": "CompanyDescription"
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
                    "label": "Type",
                    "type": "string",
                    "name": "Type"
                  },
                  {
                    "control_type": "text",
                    "label": "Number",
                    "type": "string",
                    "name": "Number"
                  },
                  {
                    "control_type": "text",
                    "label": "Date",
                    "type": "string",
                    "name": "Date"
                  },
                  {
                    "control_type": "text",
                    "label": "Accounting date",
                    "type": "string",
                    "name": "AccountingDate"
                  },
                  {
                    "control_type": "text",
                    "label": "Date to pay",
                    "type": "string",
                    "name": "DateToPay"
                  },
                  {
                    "control_type": "number",
                    "label": "Amount",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "Amount"
                  },
                  {
                    "control_type": "text",
                    "label": "Notes",
                    "type": "string",
                    "name": "Notes"
                  },
                  {
                    "control_type": "checkbox",
                    "label": "On hold",
                    "type": "boolean",
                    "name": "OnHold"
                  }
                ]
              },
              {
                "name": "VendorInvoicesDetails",
                "type": "array",
                "of": "object",
                "label": "Vendor Invoices Details",
                "properties": [
                  {
                    "control_type": "number",
                    "label": "Vendor invoice key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "VendorInvoiceKey"
                  },
                  {
                    "control_type": "number",
                    "label": "Transaction key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "TransactionKey"
                  },
                  {
                    "control_type": "number",
                    "label": "Project key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ProjectKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Project description",
                    "type": "string",
                    "name": "ProjectDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Project ID",
                    "type": "string",
                    "name": "ProjectID"
                  },
                  {
                    "control_type": "number",
                    "label": "Phase key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "PhaseKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Phase description",
                    "type": "string",
                    "name": "PhaseDescription"
                  },
                  {
                    "control_type": "text",
                    "label": "Phase ID",
                    "type": "string",
                    "name": "PhaseID"
                  },
                  {
                    "control_type": "number",
                    "label": "Activity key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "ActivityKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Activity description",
                    "type": "string",
                    "name": "ActivityDescription"
                  },
                  {
                    "control_type": "number",
                    "label": "Company key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "CompanyKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Company description",
                    "type": "string",
                    "name": "CompanyDescription"
                  },
                  {
                    "control_type": "number",
                    "label": "Units",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "Units"
                  },
                  {
                    "control_type": "text",
                    "label": "Unit description",
                    "type": "string",
                    "name": "UnitDescription"
                  },
                  {
                    "control_type": "number",
                    "label": "Cost rate",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "CostRate"
                  },
                  {
                    "control_type": "number",
                    "label": "Cost amount",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "CostAmount"
                  },
                  {
                    "control_type": "number",
                    "label": "Account key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "AccountKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Account description",
                    "type": "string",
                    "name": "AccountDescription"
                  },
                  {
                    "control_type": "number",
                    "label": "Department key",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "DepartmentKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Department description",
                    "type": "string",
                    "name": "DepartmentDescription"
                  },
                  {
                    "control_type": "checkbox",
                    "label": "Hold",
                    "type": "boolean",
                    "name": "Hold"
                  },
                  {
                    "control_type": "checkbox",
                    "label": "Non 1099",
                    "type": "boolean",
                    "name": "Non_1099"
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
            "label": "Usage key",
            "type": "string",
            "name": "UsageKey"
          }
        ]
      end
    },

    list_vendor_invoices_output: {
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
                "label": "Vendor Invoices",
                "type": "array",
                "of": "object",
                "name": "VendorInvoices",
                "properties": [
                  {
                    "control_type": "number",
                    "label": "Vendor Invoice Key",
                    "parse_output": "integer_conversion",
                    "type": "number",
                    "name": "VendorInvoiceKey"
                  },
                  {
                    "control_type": "number",
                    "label": "Vendor Key",
                    "parse_output": "integer_conversion",
                    "type": "number",
                    "name": "VendorKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Vendor Description",
                    "type": "string",
                    "name": "VendorDescription"
                  },
                  {
                    "control_type": "number",
                    "label": "Vendor Type Key",
                    "parse_output": "integer_conversion",
                    "type": "number",
                    "name": "VendorTypeKey"
                  },
                  {
                    "control_type": "text",
                    "label": "Vendor Type Description",
                    "type": "string",
                    "name": "VendorTypeDescription"
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
                    "label": "Type",
                    "type": "string",
                    "name": "Type"
                  },
                  {
                    "control_type": "text",
                    "label": "Number",
                    "type": "string",
                    "name": "Number"
                  },
                  {
                    "control_type": "date",
                    "label": "Date",
                    "type": "date",
                    "name": "Date"
                  },
                  {
                    "control_type": "date",
                    "label": "Accounting Date",
                    "type": "date",
                    "name": "AccountingDate"
                  },
                  {
                    "control_type": "date",
                    "label": "Date To Pay",
                    "type": "date",
                    "name": "DateToPay"
                  },
                  {
                    "control_type": "number",
                    "label": "Amount",
                    "parse_output": "float_conversion",
                    "type": "number",
                    "name": "Amount"
                  },
                  {
                    "control_type": "text",
                    "label": "Notes",
                    "type": "string",
                    "name": "Notes"
                  },
                  {
                    "control_type": "checkbox",
                    "label": "On Hold",
                    "type": "boolean",
                    "name": "OnHold"
                  },
                  {
                    "control_type": "checkbox",
                    "label": "Partially On Hold",
                    "type": "boolean",
                    "name": "PartiallyOnHold"
                  }
                ]
              },
              {
                "control_type": "array",
                "label": "Vendor Invoices Details",
                "type": "array",
                "of": "object",
                "name": "VendorInvoicesDetails",
                "properties": []
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
    }

    
  },
  custom_action: true,

  custom_action_help: {
    learn_more_url: "https://help.deltek.com/Product/Ajera/api/index.html",

    learn_more_text: "Learm more",

    body: "<p>Build your own Deltek Ajera action with a HTTP request. <b>The request will be authorized with your Ajera connection.</b></p>"
  }
}
