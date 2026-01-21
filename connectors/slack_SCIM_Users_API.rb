{
  title: "Slack - SCIM Users Endpoint - https://api.slack.com/scim#users",
  
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
    }
  },
  
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
        [
          { name: "userName", label: "Username", optional: false },
          { name: "givenName", label: "First Name", optional: false },
          { name: "familyName", label: "Last Name", optional: false },
          { name: "email", label: "Email Address", optional: false },
          { name: "externalId", label: "External ID", optional: true },
          { name: "active", type: "boolean", label: "Active", optional: true, default: true }
        ]
      end,
      
      execute: lambda do |connection, input|
        post("/scim/#{connection['scim_version']}/Users", {
          schemas: ["urn:scim:schemas:core:1.0"],
          userName: input["userName"],
          name: {
            givenName: input["givenName"],
            familyName: input["familyName"]
          },
          emails: [
            {
              value: input["email"],
              type: "work",
              primary: true
            }
          ],
          active: input["active"].nil? ? true : input["active"]
        }.compact.merge(
          input["externalId"].present? ? { externalId: input["externalId"] } : {}
        ))
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions["user"]
      end
    },
    
    update_user: {
      title: "Update user",
      description: "Update an existing <span class='provider'>user</span>",
      
      input_fields: lambda do |object_definitions|
        [
          { name: "id", label: "User ID", optional: false },
          { name: "userName", label: "Username", optional: true },
          { name: "givenName", label: "First Name", optional: true },
          { name: "familyName", label: "Last Name", optional: true },
          { name: "email", label: "Email Address", optional: true },
          { name: "active", type: "boolean", label: "Active", optional: true }
        ]
      end,
      
      execute: lambda do |connection, input|
        # First get the current user
        user = get("/scim/#{connection['scim_version']}/Users/#{input['id']}")
        
        # Prepare update payload
        update_payload = user.merge(
          {
            userName: input["userName"] || user["userName"],
            name: {
              givenName: input["givenName"] || user.dig("name", "givenName"),
              familyName: input["familyName"] || user.dig("name", "familyName")
            },
            active: input["active"].nil? ? user["active"] : input["active"]
          }
        )
        
        # Update email if provided
        if input["email"].present?
          update_payload[:emails] = [
            {
              value: input["email"],
              type: "work",
              primary: true
            }
          ]
        end
        
        put("/scim/#{connection['scim_version']}/Users/#{input['id']}", update_payload)
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions["user"]
      end
    },
    
    patch_user: {
      title: "Patch user (partial update)",
      description: "Partially update a <span class='provider'>user</span>",
      
      input_fields: lambda do |object_definitions|
        [
          { name: "id", label: "User ID", optional: false },
          { name: "givenName", label: "First Name", optional: true },
          { name: "familyName", label: "Last Name", optional: true },
          { name: "active", type: "boolean", label: "Active", optional: true }
        ]
      end,
      
      execute: lambda do |connection, input|
        patch_data = {}
        
        if input["givenName"].present? || input["familyName"].present?
          patch_data[:name] = {}
          patch_data[:name][:givenName] = input["givenName"] if input["givenName"].present?
          patch_data[:name][:familyName] = input["familyName"] if input["familyName"].present?
        end
        
        patch_data[:active] = input["active"] if !input["active"].nil?
        
        patch("/scim/#{connection['scim_version']}/Users/#{input['id']}", patch_data)
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions["user"]
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
    new_or_updated_user: {
      title: "New or updated user",
      description: "Triggers when a <span class='provider'>user</span> is created or updated",
      
      type: :paging_desc,
      
      input_fields: lambda do |object_definitions|
        []
      end,
      
      poll: lambda do |connection, input, closure|
        page_size = 100
        closure = closure.presence || { offset: 1 }
        
        response = get("/scim/#{connection['scim_version']}/Users", {
          count: page_size,
          startIndex: closure[:offset]
        })
        
        users = response["Resources"] || []
        
        next_closure = 
          if users.length >= page_size
            { offset: closure[:offset] + page_size }
          else
            nil
          end
        
        {
          events: users,
          next_poll: next_closure,
          can_poll_more: !next_closure.nil?
        }
      end,
      
      document_id: lambda do |user|
        user["id"]
      end,
      
      sort_by: lambda do |user|
        user["meta"]["lastModified"] rescue user["id"]
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions["user"]
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