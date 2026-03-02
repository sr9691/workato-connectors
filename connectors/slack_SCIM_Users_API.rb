{
  title: "Slack - SCIM Users Endpoint",
  # https://api.slack.com/scim#users
  
  connection: {
    fields: [
      {
        name: "access_token",
        label: "OAuth Access Token",
        hint: "User OAuth token with 'admin' scope (starts with xoxp-)",
        optional: false,
        control_type: "password"
      },
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
    get("/scim/#{connection['scim_version']}/ServiceProviderConfig")
  end,
    
  actions: {
    # User Actions
    get_user: {
      title: "Get user by ID",
      description: "Retrieve a <span class='provider'>user</span> by ID",
      
      input_fields: lambda do |object_definitions|
        [
          { name: "id", label: "User ID", optional: false, hint: "Slack user ID (starts with U or W)" }
        ]
      end,
      
      execute: lambda do |connection, input|
        get("/scim/#{connection['scim_version']}/Users/#{input['id']}")
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions["user"]
      end
    },
    
    search_users: {
      title: "Search users",
      description: "Search <span class='provider'>users</span> with filter",
      
      input_fields: lambda do |object_definitions|
        [
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
        
        get("/scim/#{connection['scim_version']}/Users", params)
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
      title: "Create user",
      description: "Create a new <span class='provider'>user</span>",
      
      input_fields: lambda do |object_definitions|
        object_definitions[:create_user_input]
      end,
      
      execute: lambda do |connection, input|
        # input["schemas"] ||= ["urn:scim:schemas:core:1.0"]
        
        post("/scim/#{connection['scim_version']}/Users", input)
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions["user"].concat(object_definitions["error_response"])
      end
    },
    
    delete_user: {
      title: "Delete user",
      description: "Delete a <span class='provider'>user</span>",
      
      input_fields: lambda do |object_definitions|
        [
          { name: "id", label: "User ID", optional: false }
        ]
      end,
      
      execute: lambda do |connection, input|
        delete("/scim/#{connection['scim_version']}/Users/#{input['id']}")
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
      title: "Get group by ID",
      description: "Retrieve a <span class='provider'>group</span> by ID",
      
      input_fields: lambda do |object_definitions|
        [
          { name: "id", label: "Group ID", optional: false }
        ]
      end,
      
      execute: lambda do |connection, input|
        get("/scim/#{connection['scim_version']}/Groups/#{input['id']}")
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions["group"]
      end
    },
    
    search_groups: {
      title: "Search groups",
      description: "Search <span class='provider'>groups</span>",
      
      input_fields: lambda do |object_definitions|
        [
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
        
        get("/scim/#{connection['scim_version']}/Groups", params)
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
              { name: 'primary', type: 'boolean', optional: true }
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
          { name: 'active', type: 'boolean', optional: true },
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
    # Helper methods can be added here
  }
}