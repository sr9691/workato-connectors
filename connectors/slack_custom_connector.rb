{
  title: "Slack - Custom connector",
  
  connection: {
    fields: [
      {
        name: "access_token",
        label: "OAuth Access Token",
        hint: "User OAuth token with 'admin' scope (starts with xoxp-)",
        optional: false,
        control_type: "password"
      },
      #{
      #  name: "scim_version",
      #  label: "SCIM API Version",
      #  hint: "Select SCIM API version",
      #  control_type: "select",
      #  pick_list: [
      #    ["SCIM v1", "v1"],
      #    ["SCIM v2", "v2"]
      #  ],
      #  optional: false,
      #  default: "v2"
      #}
    ],
    
    authorization: {
      type: "custom_auth",
      
      credentials: lambda do |connection|
        headers("Authorization": "Bearer #{connection['access_token']}")
      end
    },
    
    base_uri: lambda do |connection|
      "https://api.slack.com/scim/#{connection['scim_version']}"
    end
  },
  
  test: lambda do |connection|
    # Test connection by fetching service provider config
    get("/scim/v1/ServiceProviderConfig")
  end,
    
  actions: {
    # User Actions
    get_user: {
      title: "USER - Get user by ID",
      description: "Retrieve a <span class='provider'>user</span> by ID",
      
      input_fields: lambda do |object_definitions|
         [
          {
            name: "scim_version",
            label: "SCIM API Version",
            hint: "Select SCIM API version",
            control_type: "select",
            pick_list: [
              ["SCIM v1", "v1"]
              # ["SCIM v2", "v2"]
            ],
            optional: false,
            default: "v2"
          },
          { name: "id", label: "User ID", optional: false, hint: "Slack user ID (starts with U or W)" }
        ]
      end,
      
      execute: lambda do |connection, input|
        get("/scim/#{input['scim_version']}/Users/#{input['id']}")
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions["user"]
      end
    },
    
    search_users: {
      title: "USER - Search users",
      description: "Search <span class='provider'>users</span> with filter",
      
      input_fields: lambda do |object_definitions|
        [
         {
            name: "scim_version",
            label: "SCIM API Version",
            hint: "Select SCIM API version",
            control_type: "select",
            pick_list: [
              ["SCIM v1", "v1"],
              ["SCIM v2", "v2"]
            ],
            optional: false,
            default: "v2"
          },
          { 
            name: "filter", 
            label: "Filter", 
            optional: true,
            hint: "SCIM filter (e.g., 'userName eq \"user@example.com\"')" 
          },
          { 
            name: "count", 
            type: "integer",
            label: "Count", 
            optional: true,
            default: 100,
            hint: "Number of results to return (max 1000)"
          },
          { 
            name: "startIndex", 
            type: "integer",
            label: "Start Index", 
            optional: true,
            default: 1,
            hint: "1-based index for pagination"
          }
        ]
      end,
      
      execute: lambda do |connection, input|
        params = {
          count: input["count"] || 100,
          startIndex: input["startIndex"] || 1
        }
        params[:filter] = input["filter"] if input["filter"].present?
        
        get("/scim/#{input['scim_version']}/Users", params)
      end,
      
      output_fields: lambda do |object_definitions|
        [
          { name: "totalResults", type: "integer", label: "Total Results" },
          { name: "itemsPerPage", type: "integer", label: "Items Per Page" },
          { name: "startIndex", type: "integer", label: "Start Index" },
          { name: "schemas", type: "array", of: "string" },
          {
            name: "Resources",
            type: "array",
            of: "object",
            properties: object_definitions["user"]
          }
        ]
      end
    },
    
    create_user: {
      title: "USER - Create user",
      description: "Create a new <span class='provider'>user</span>",
      
      input_fields: lambda do |object_definitions|
        [
          {
            name: "scim_version",
            label: "SCIM API Version",
            hint: "Select SCIM API version",
            control_type: "select",
            pick_list: [
              ["SCIM v1", "v1"],
              ["SCIM v2", "v2"]
            ],
            optional: false,
            default: "v2"
          }
        ].concat(object_definitions["create_user_input"])
      end,
      
      execute: lambda do |connection, input|
        # input["schemas"] ||= ["urn:scim:schemas:core:1.0"]
        
        post("/scim/#{input['scim_version']}/Users", input)
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions["user"].concat(object_definitions["error_response"])
      end
    },
    
    delete_user: {
      title: "USER - Delete user",
      description: "Delete a <span class='provider'>user</span>",
      
      input_fields: lambda do |object_definitions|
        [
         {
            name: "scim_version",
            label: "SCIM API Version",
            hint: "Select SCIM API version",
            control_type: "select",
            pick_list: [
              ["SCIM v1", "v1"],
              ["SCIM v2", "v2"]
            ],
            optional: false,
            default: "v2"
          },
          { name: "id", label: "User ID", optional: false }
        ]
      end,
      
      execute: lambda do |connection, input|
        delete("/scim/#{input['scim_version']}/Users/#{input['id']}")
        { success: true, id: input['id'] }
      end,
      
      output_fields: lambda do |object_definitions|
        [
          { name: "success", type: "boolean" },
          { name: "id", type: "string" }
        ]
      end
    },
    
    # Group Actions
    get_group: {
      title: "USER - Get group by ID",
      description: "Retrieve a <span class='provider'>group</span> by ID",
      
      input_fields: lambda do |object_definitions|
        [
         {
            name: "scim_version",
            label: "SCIM API Version",
            hint: "Select SCIM API version",
            control_type: "select",
            pick_list: [
              ["SCIM v1", "v1"],
              ["SCIM v2", "v2"]
            ],
            optional: false,
            default: "v2"
          },
          { name: "id", label: "Group ID", optional: false }
        ]
      end,
      
      execute: lambda do |connection, input|
        get("/scim/#{input['scim_version']}/Groups/#{input['id']}")
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions["group"]
      end
    },
    
    search_groups: {
      title: "USER - Search groups",
      description: "Search <span class='provider'>groups</span>",
      
      input_fields: lambda do |object_definitions|
        [
         {
            name: "scim_version",
            label: "SCIM API Version",
            hint: "Select SCIM API version",
            control_type: "select",
            pick_list: [
              ["SCIM v1", "v1"],
              ["SCIM v2", "v2"]
            ],
            optional: false,
            default: "v2"
          },
          { 
            name: "filter", 
            label: "Filter", 
            optional: true,
            hint: "SCIM filter" 
          },
          { 
            name: "count", 
            type: "integer",
            label: "Count", 
            optional: true,
            default: 100
          }
        ]
      end,
      
      execute: lambda do |connection, input|
        params = { count: input["count"] || 100 }
        params[:filter] = input["filter"] if input["filter"].present?
        
        get("/scim/#{input['scim_version']}/Groups", params)
      end,
      
      output_fields: lambda do |object_definitions|
        [
          { name: "totalResults", type: "integer" },
          { name: "itemsPerPage", type: "integer" },
          { name: "startIndex", type: "integer" },
          {
            name: "Resources",
            type: "array",
            of: "object",
            properties: object_definitions["group"]
          }
        ]
      end
    },
    
    get_billing_info: {
      title: 'BILLING - Get team billing information',
      subtitle: 'Retrieve billing plan details for the workspace',
      description: 'Get the billing plan type (free, std, plus, enterprise, compliance) for the Slack workspace',
      
      input_fields: lambda do |object_definitions|
        [
          {
            name: 'team_id',
            label: 'Team ID',
            hint: 'Optional. Only needed for org-level tokens',
            optional: true
          }
        ]
      end,
      
      execute: lambda do |connection, input, input_schema, output_schema|
        params = {}
        params['team'] = input['team_id'] if input['team_id'].present?
        
        response = get('https://slack.com/api/team.billing.info', params)
        
        # Return the response
        response
      end,
      
      output_fields: lambda do |object_definitions|
        [
          {
            name: 'ok',
            type: 'boolean',
            label: 'Success'
          },
          {
            name: 'plan',
            label: 'Billing Plan',
            hint: 'Plan type: free, std, plus, enterprise, or compliance'
          },
          {
            name: 'error',
            label: 'Error message',
            hint: 'Present if ok is false'
          }
        ]
      end,
      
      sample_output: lambda do |connection, input|
        {
          'ok' => true,
          'plan' => 'std'
        }
      end
    },
    
    get_billable_info: {
      title: 'BILLING - List billable information (with pagination)',
      subtitle: 'Get billable users information for the team',
      description: 'Retrieves billable information for users on the Slack team',
      help: 'This action returns billing status for team members based on Slack\'s Fair Billing policy',

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'user',
            label: 'User ID',
            optional: true,
            hint: 'Slack user ID (e.g., U1234567890). Leave empty to get all users.'
          },
          {
            name: 'cursor',
            label: 'Cursor',
            optional: true,
            hint: 'Pagination cursor from previous response'
          },
          {
            name: 'limit',
            label: 'Limit',
            type: 'integer',
            optional: true,
            hint: 'Maximum number of items to return (default: 100)'
          }
        ]
      end,

      execute: lambda do |connection, input|
        params = {}
        params['user'] = input['user'] if input['user'].present?
        params['cursor'] = input['cursor'] if input['cursor'].present?
        params['limit'] = input['limit'] if input['limit'].present?

        response = get('/api/team.billableInfo').
                     params(params).
                     after_error_response(/.*/) do |code, body, headers, message|
                       error("#{code}: #{body}")
                     end

        response
      end,

      output_fields: lambda do |object_definitions|
        [
          {
            name: 'ok',
            type: 'boolean',
            label: 'Success'
          },
          {
            name: 'billable_info',
            type: 'object',
            label: 'Billable information',
            properties: [
              {
                name: 'billing_active',
                type: 'boolean',
                label: 'Billing active'
              }
            ]
          },
          {
            name: 'response_metadata',
            type: 'object',
            label: 'Response metadata',
            properties: [
              {
                name: 'next_cursor',
                label: 'Next cursor'
              }
            ]
          }
        ]
      end,

      sample_output: lambda do |connection, input|
        {
          ok: true,
          billable_info: {
            "U0632EWRW": {
              billing_active: false
            },
            "U02UCPE1R": {
              billing_active: true
            },
            "U02UEBSD2": {
              billing_active: true
            }
          },
          response_metadata: {
            next_cursor: ""
          }
        }
      end
    },

    get_team_info: {
      title: 'TEAM - Get team information',
      subtitle: 'Get basic team info',
      description: 'Retrieves basic information about the Slack team/workspace',

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'team',
            label: 'Team ID',
            optional: true,
            hint: 'Team ID to get info about (optional)'
          }
        ]
      end,

      execute: lambda do |connection, input|
        params = {}
        params['team'] = input['team'] if input['team'].present?

        response = get('/api/team.info').
                     params(params).
                     after_error_response(/.*/) do |code, body, headers, message|
                       error("#{code}: #{body}")
                     end

        response
      end,

      output_fields: lambda do |object_definitions|
        [
          {
            name: 'ok',
            type: 'boolean'
          },
          {
            name: 'team',
            type: 'object',
            properties: [
              { name: 'id', label: 'Team ID' },
              { name: 'name', label: 'Team name' },
              { name: 'domain', label: 'Domain' },
              { name: 'email_domain', label: 'Email domain' },
              {
                name: 'icon',
                type: 'object',
                properties: [
                  { name: 'image_default', type: 'boolean' },
                  { name: 'image_34' },
                  { name: 'image_44' },
                  { name: 'image_68' },
                  { name: 'image_88' },
                  { name: 'image_102' },
                  { name: 'image_132' }
                ]
              },
              { name: 'enterprise_id', label: 'Enterprise ID', optional: true },
              { name: 'enterprise_name', label: 'Enterprise name', optional: true }
            ]
          }
        ]
      end,

      sample_output: lambda do |connection, input|
        {
          ok: true,
          team: {
            id: "T12345",
            name: "My Team",
            domain: "example",
            email_domain: "example.com",
            icon: {
              image_34: "https://...",
              image_44: "https://...",
              image_68: "https://...",
              image_88: "https://...",
              image_102: "https://...",
              image_132: "https://...",
              image_default: true
            }
          }
        }
      end
    },

    list_all_billable_users: {
      title: 'BILLING - List all billable users (auto pagination)',
      subtitle: 'Get all billable users',
      description: 'Retrieves all billable users, handling pagination automatically',
      help: 'This action will fetch all billable users across multiple pages',

      execute: lambda do |connection, input|
        billable_users = []
        cursor = nil
        
        loop do
          params = { limit: 100 }
          params['cursor'] = cursor if cursor.present?
          
          response = get('/api/team.billableInfo').
                       params(params).
                       after_error_response(/.*/) do |code, body, headers, message|
                         error("#{code}: #{body}")
                       end
          
          if response['billable_info'].present?
            response['billable_info'].each do |user_id, info|
              billable_users << {
                user_id: user_id,
                billing_active: info['billing_active']
              }
            end
          end
          
          cursor = response.dig('response_metadata', 'next_cursor')
          break if cursor.blank?
        end
        
        {
          users: billable_users,
          total_count: billable_users.length,
          active_count: billable_users.count { |u| u[:billing_active] },
          inactive_count: billable_users.count { |u| !u[:billing_active] }
        }
      end,

      output_fields: lambda do |object_definitions|
        [
          {
            name: 'users',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'user_id', label: 'User ID' },
              { name: 'billing_active', type: 'boolean', label: 'Billing active' }
            ]
          },
          { name: 'total_count', type: 'integer', label: 'Total users' },
          { name: 'active_count', type: 'integer', label: 'Active billable users' },
          { name: 'inactive_count', type: 'integer', label: 'Inactive users' }
        ]
      end,

      sample_output: lambda do |connection, input|
        {
          users: [
            { user_id: "U0632EWRW", billing_active: false },
            { user_id: "U02UCPE1R", billing_active: true },
            { user_id: "U02UEBSD2", billing_active: true }
          ],
          total_count: 3,
          active_count: 2,
          inactive_count: 1
        }
      end
    },
    
    get_team_access_logs: {
      title: "TEAM - Get access logs",
      description: "Retrieve team access logs with automatic pagination",
      
      input_fields: lambda do |object_definitions|
        [
          {
            name: "before",
            label: "Before",
            type: "string",
            control_type: "text",
            optional: true,
            hint: "End of time range of logs to include (Unix timestamp). Defaults to now."
          },
          {
            name: "count",
            label: "Count per page",
            type: "integer",
            control_type: "number",
            optional: true,
            hint: "Number of items to return per page (max 1000, default 100)"
          },
          {
            name: "limit",
            label: "Total limit",
            type: "integer",
            control_type: "number",
            optional: true,
            hint: "Maximum total number of logs to retrieve across all pages. Leave empty for all logs."
          }
        ]
      end,
      
      execute: lambda do |connection, input|
        all_logs = []
        page = 1
        has_more = true
        count = input["count"] || 100
        limit = input["limit"]
        
        while has_more
          params = {
            count: count,
            page: page
          }
          params[:before] = input["before"] if input["before"].present?
          
          response = get("https://slack.com/api/team.accessLogs").params(params)
          
          # Check for Slack API error
          call("check_slack_error", response)
          
          # Add logs from this page
          all_logs.concat(response["logins"] || [])
          
          # Check if we should continue
          has_more = response["paging"]["pages"].to_i > page
          
          # Check if we've hit the user-specified limit
          if limit.present? && all_logs.length >= limit
            all_logs = all_logs.first(limit)
            has_more = false
          end
          
          page += 1
        end
        
        {
          logins: all_logs,
          total_count: all_logs.length
        }
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions[:team_access_logs_output]
      end
    }
  },
  
  triggers: {

  },

  object_definitions: {
    user: {
      fields: lambda do |connection, config_fields|
        [
          { name: "id", type: "string", label: "User ID" },
          { name: "externalId", type: "string", label: "External ID" },
          { name: "userName", type: "string", label: "Username" },
          { name: "active", type: "boolean", label: "Active" },
          { 
            name: "name", 
            type: "object",
            properties: [
              { name: "givenName", type: "string", label: "First Name" },
              { name: "familyName", type: "string", label: "Last Name" }
            ]
          },
          {
            name: "emails",
            type: "array",
            of: "object",
            properties: [
              { name: "value", type: "string", label: "Email Address" },
              { name: "type", type: "string", label: "Email Type" },
              { name: "primary", type: "boolean", label: "Primary" }
            ]
          },
          { name: "displayName", type: "string", label: "Display Name" },
          { name: "nickName", type: "string", label: "Nick Name" },
          { name: "profileUrl", type: "string", label: "Profile URL" },
          { name: "title", type: "string", label: "Job Title" },
          { name: "timezone", type: "string", label: "Timezone" },
          { name: "locale", type: "string", label: "Locale" },
          {
            name: "photos",
            type: "array",
            of: "object",
            properties: [
              { name: "value", type: "string", label: "Photo URL" },
              { name: "type", type: "string", label: "Photo Type" }
            ]
          }
        ]
      end
    },
    
    group: {
      fields: lambda do |connection, config_fields|
        [
          { name: "id", type: "string", label: "Group ID" },
          { name: "displayName", type: "string", label: "Display Name" },
          {
            name: "members",
            type: "array",
            of: "object",
            properties: [
              { name: "value", type: "string", label: "User ID" },
              { name: "display", type: "string", label: "Display Name" }
            ]
          }
        ]
      end
    },
    
    create_user_input: {
      fields: lambda do |_connection, _config_fields|
        [
          {
            name: 'schemas',
            type: 'array',
            of: 'string',
            optional: false
          },
          { name: 'userName', type: 'string', optional: false },
          { name: 'nickName', type: 'string', optional: true },
          {
            name: 'name',
            type: 'object',
            optional: true,
            properties: [
              { name: 'familyName', type: 'string', optional: true },
              { name: 'givenName', type: 'string', optional: true },
              { name: 'honorificPrefix', type: 'string', optional: true }
            ]
          },
          { name: 'displayName', type: 'string', optional: true },
          { name: 'profileUrl', type: 'string', optional: true },
          {
            name: 'emails',
            type: 'array',
            of: 'object',
            optional: false,
            properties: [
              { name: 'value', type: 'string', optional: false },
              { name: 'type', type: 'string', optional: true },
              { name: 'primary', type: 'boolean', optional: false }
            ]
          },
          {
            name: 'addresses',
            type: 'array',
            of: 'object',
            optional: true,
            properties: [
              { name: 'streetAddress', type: 'string', optional: true },
              { name: 'locality', type: 'string', optional: true },
              { name: 'region', type: 'string', optional: true },
              { name: 'postalCode', type: 'string', optional: true },
              { name: 'country', type: 'string', optional: true },
              { name: 'primary', type: 'boolean', optional: true }
            ]
          },
          {
            name: 'phoneNumbers',
            type: 'array',
            of: 'object',
            optional: true,
            properties: [
              { name: 'value', type: 'string', optional: true },
              { name: 'type', type: 'string', optional: true }
            ]
          },
          {
            name: 'photos',
            type: 'array',
            of: 'object',
            optional: true,
            properties: [
              { name: 'value', type: 'string', optional: true },
              { name: 'type', type: 'string', optional: true }
            ]
          },
          {
            name: 'roles',
            type: 'array',
            of: 'object',
            optional: true,
            properties: [
              { name: 'value', type: 'string', optional: true },
              { name: 'primary', type: 'string', optional: true }
            ]
          },
          { name: 'userType', type: 'string', optional: true },
          { name: 'title', type: 'string', optional: true },
          { name: 'preferredLanguage', type: 'string', optional: true },
          { name: 'locale', type: 'string', optional: true },
          { name: 'timezone', type: 'string', optional: true },
          { name: 'active', type: 'boolean', optional: false },
          { name: 'password', type: 'string', optional: true },
          {
            name: 'urn:scim:schemas:extension:enterprise:1.0',
            type: 'object',
            optional: true,
            properties: [
              { name: 'employeeNumber', type: 'string', optional: true },
              { name: 'costCenter', type: 'string', optional: true },
              { name: 'organization', type: 'string', optional: true },
              { name: 'division', type: 'string', optional: true },
              { name: 'department', type: 'string', optional: true },
              {
                name: 'manager',
                type: 'object',
                optional: true,
                properties: [
                  { name: 'managerId', type: 'string', optional: true }
                ]
              }
            ]
          },
          {
            name: 'urn:scim:schemas:extension:slack:profile:1.0',
            type: 'object',
            optional: true,
            properties: [
              { name: 'startDate', type: 'string', optional: true }
            ]
          }
        ]
      end
    },
    
        team_access_logs_output: {
      fields: lambda do |connection, config_fields|
        [
          {
            name: "logins",
            type: "array",
            of: "object",
            label: "Logins",
            properties: [
              {
                name: "user_id",
                label: "User ID",
                type: "string",
                control_type: "text"
              },
              {
                name: "username",
                label: "Username",
                type: "string",
                control_type: "text"
              },
              {
                name: "date_first",
                label: "First access",
                type: "integer",
                control_type: "number",
                hint: "Unix timestamp of first access"
              },
              {
                name: "date_last",
                label: "Last access",
                type: "integer",
                control_type: "number",
                hint: "Unix timestamp of last access"
              },
              {
                name: "count",
                label: "Access count",
                type: "integer",
                control_type: "number",
                hint: "Number of access events"
              },
              {
                name: "ip",
                label: "IP address",
                type: "string",
                control_type: "text"
              },
              {
                name: "user_agent",
                label: "User agent",
                type: "string",
                control_type: "text"
              },
              {
                name: "isp",
                label: "ISP",
                type: "string",
                control_type: "text",
                hint: "Internet Service Provider"
              },
              {
                name: "country",
                label: "Country",
                type: "string",
                control_type: "text"
              },
              {
                name: "region",
                label: "Region",
                type: "string",
                control_type: "text"
              }
            ]
          },
          {
            name: "total_count",
            label: "Total count",
            type: "integer",
            control_type: "number",
            hint: "Total number of logs retrieved"
          }
        ]
      end
    },
    
    error_response: {
      fields: lambda do |_connection, _config_fields|
        [
          {
            name: 'Errors',
            type: 'object',
            properties: [
              { name: 'description', type: 'string' },
              { name: 'code', type: 'integer' }
            ]
          }
        ]
      end
    }

  },
  
  pick_lists: {
    # Add any pick lists if needed
  },
  
  methods: {
    check_slack_error: lambda do |response|
      unless response["ok"]
        error_message = response["error"] || "Unknown Slack API error"
        error(error_message)
      end
    end
  }
}