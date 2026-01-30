{
  title: "Atlassian Jira Users (Custom) - https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-users/",

  # Connection configuration
  connection: {
    fields: [
      {
        name: "client_id",
        label: "Client ID",
        optional: false,
        hint: "Your OAuth 2.0 Client ID from Atlassian Developer Console"
      },
      {
        name: "client_secret",
        label: "Client Secret",
        control_type: "password",
        optional: false,
        hint: "Your OAuth 2.0 Client Secret from Atlassian Developer Console"
      }
      
    ],

    authorization: {
      type: "oauth2",

      # Authorization URL - where user grants permissions
      authorization_url: lambda do |connection|
        params = {
          audience: "api.atlassian.com",
          client_id: connection["client_id"],
          scope: "read:jira-user read:jira-work write:jira-work manage:jira-configuration offline_access read:license:jira READ",
          redirect_uri: "https://www.workato.com/oauth/callback",
          response_type: "code",
          prompt: "consent"
        }.to_param

        "https://auth.atlassian.com/authorize?#{params}"
      end,

      # Token URL - where we exchange auth code for access token
      token_url: lambda do |connection|
        "https://auth.atlassian.com/oauth/token"
      end,

      # Client credentials
      client_id: lambda do |connection|
        connection["client_id"]
      end,

      client_secret: lambda do |connection|
        connection["client_secret"]
      end,

      # How to use the access token in API requests
      apply: lambda do |connection, access_token|
        headers("Authorization": "Bearer #{access_token}")
      end,

      # Refresh token configuration
      refresh_on: [401, 403],
      
      refresh: lambda do |connection, refresh_token|
        response = post("https://auth.atlassian.com/oauth/token").
          payload(
            grant_type: "refresh_token",
            client_id: connection["client_id"],
            client_secret: connection["client_secret"],
            refresh_token: refresh_token
          ).
          request_format_json

        [
          {
            access_token: response["access_token"],
            refresh_token: response["refresh_token"]
          }
        ]
      end,

      # Detect failed authorization
      detect_on: [
        /Unauthorized/,
        /Authentication failed/,
        /Invalid token/
      ]
    },

    # Base URL will be dynamically constructed per request
    base_uri: lambda do |connection|
      # This is a placeholder - actual base_uri will use cloud_id
      ""
    end
  },

  # Test connection
  test: lambda do |connection|
    # Get accessible resources to verify connection
    get("https://api.atlassian.com/oauth/token/accessible-resources")
  end,

  # Actions
  actions: {
    # Get accessible resources (sites)
    get_accessible_resources: {
      title: "Acessible resources",
      subtitle: "Acessible resources",
      description: "Get list of <span class='provider'>Jira sites</span> accessible to the authenticated user",

      execute: lambda do |connection, input|
        {
          resources: get("https://api.atlassian.com/oauth/token/accessible-resources")
        }
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "resources", type: "array", of: "object",
            properties: object_definitions["cloud_resource"] }
        ]
      end
    },
    
    get_jira_instance_license: {
      title: "LICENSE - Get license",
      description: "Returns licensing information about the Jira instance.",
      
      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Jira Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Jira site" }
        ]
      end,
      
      execute: lambda do |connection, input|
          get("https://api.atlassian.com/ex/jira/#{input['cloud_id']}/rest/api/3/instance/license")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:instance_license_output]
      end
    },
    
    get_aproximate_license_count: {
      title: "LICENSE - Get approximate license count",
      description: "Returns the approximate number of user accounts across all Jira licenses. Note that this information is cached with a 7-day lifecycle and could be stale at the time of call.",
      
      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Jira Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Jira site" }
        ]
      end,
      
      execute: lambda do |connection, input|
          get("https://api.atlassian.com/ex/jira/#{input['cloud_id']}/rest/api/3/license/approximateLicenseCount'")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:approximate_license_count_output]
      end
    },
    
    get_aproximate_application_license_count: {
      title: "LICENSE - Get approximate application license count",
      description: "Returns the total approximate number of user accounts for a single Jira license. Note that this information is cached with a 7-day lifecycle and could be stale at the time of call.",
      
      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Jira Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Jira site" },
          {
            name: "application_key",
            label: "Application key",
            control_type: "select",
            pick_list: [
              ["Jira Core", "jira-core"],
              ["Jira Product Discovery", "jira-product-discovery"],
              ["Jira Software", "jira-software"],
              ["Jira Service Desk", "jira-servicedesk"]
            ],
            optional: false,
            hint: "The ID of the application, represents a specific version of Jira.",
            toggle_hint: "Select from list",
            toggle_field: {
              name: "application_key",
              label: "Application key",
              type: 'string',
              control_type: "text",
              hint: "Enter a custom application key or use a datapill",
              toggle_hint: 'String value',
            }
          }
        ]
      end,
      
      execute: lambda do |connection, input|
          get("https://api.atlassian.com/ex/jira/#{input['cloud_id']}/rest/api/3/license/approximateLicenseCount/product/#{input['application_key']}'")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:approximate_license_count_output]
      end
    },

  },

  # Triggers
  triggers: {
    # Note: Jira doesn't provide real-time webhooks through OAuth 2.0 apps easily
    # These would be polling-based triggers
    new_or_updated_user: {
      subtitle: "Jira Users API",
      description: "Triggers when a <span class='provider'>user</span> is created or updated",
      
      type: :paging_desc,

      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Jira Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Jira site" },
          { name: "since", label: "When first started, this recipe should pick up events from", 
            type: "timestamp", optional: true,
            hint: "Leave blank to get users from now onwards" }
        ]
      end,

      poll: lambda do |connection, input, page|
        page ||= 0
        page_size = 50

        params = {
          startAt: page * page_size,
          maxResults: page_size
        }

        users = get("https://api.atlassian.com/ex/jira/#{input['cloud_id']}/rest/api/3/users/search").
          params(params)

        {
          events: users,
          next_page: users.length >= page_size ? page + 1 : nil
        }
      end,

      document_id: lambda do |user|
        user["accountId"]
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["user"]
      end
    }
  },
  
  # Object definitions
  object_definitions: {
    user: {
      fields: lambda do |connection, config_fields|
        [
          { name: "accountId", label: "Account ID", type: "string" },
          { name: "accountType", label: "Account Type", type: "string" },
          { name: "emailAddress", label: "Email Address", type: "string" },
          { name: "displayName", label: "Display Name", type: "string" },
          { name: "active", label: "Active", type: "boolean" },
          { name: "timeZone", label: "Time Zone", type: "string" },
          { name: "locale", label: "Locale", type: "string" },
          { name: "avatarUrls", label: "Avatar URLs", type: "object", 
            properties: [
              { name: "48x48", type: "string" },
              { name: "24x24", type: "string" },
              { name: "16x16", type: "string" },
              { name: "32x32", type: "string" }
            ]
          },
          { name: "self", label: "Self URL", type: "string" }
        ]
      end
    },

    cloud_resource: {
      fields: lambda do |connection, config_fields|
        [
          { name: "id", label: "Cloud ID", type: "string" },
          { name: "name", label: "Site Name", type: "string" },
          { name: "url", label: "Site URL", type: "string" },
          { name: "scopes", label: "Scopes", type: "array", of: "string" },
          { name: "avatarUrl", label: "Avatar URL", type: "string" }
        ]
      end
    },
    
    instance_license_output: {
      fields: lambda do |_connection, _config_fields|
        [
          {
            name: 'applications',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'id', type: 'string' },
              { name: 'plan', type: 'string' }
            ]
          }
        ]
      end
    },
    approximate_license_count_output: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: 'key', type: 'string' },
          { name: 'value', type: 'string' }
        ]
      end
    }
  },

  # Pick lists (for dropdown fields)
  pick_lists: {
    cloud_resources: lambda do |connection|
      resources = get("https://api.atlassian.com/oauth/token/accessible-resources")
      
      resources.map do |resource|
        [resource["name"], resource["id"]]
      end
    end,
  }
}