{
  title: "Atlassian Jira Users (Custom)",

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
          scope: "read:jira-user read:jira-work write:jira-work manage:jira-configuration offline_access",
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
    }
  },

  # Actions
  actions: {
    # Get accessible resources (sites)
    get_accessible_resources: {
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

    # Get user by account ID
    get_user: {
      description: "Get <span class='provider'>user details</span> by account ID",

      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Jira Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Jira site" },
          { name: "accountId", label: "Account ID", optional: false,
            hint: "The account ID of the user" }
        ]
      end,

      execute: lambda do |connection, input|
        get("https://api.atlassian.com/ex/jira/#{input['cloud_id']}/rest/api/3/user").
          params(accountId: input['accountId'])
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["user"]
      end
    },

    # Search for users
    search_users: {
      description: "Search for <span class='provider'>users</span> in Jira",

      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Jira Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Jira site" },
          { name: "query", label: "Query", optional: true,
            hint: "Query string to search for users (searches by displayName, email, etc.)" },
          { name: "maxResults", label: "Max Results", type: "integer", 
            optional: true, default: 50,
            hint: "Maximum number of users to return (default: 50)" },
          { name: "startAt", label: "Start At", type: "integer", 
            optional: true, default: 0,
            hint: "Index of the first user to return (for pagination)" }
        ]
      end,

      execute: lambda do |connection, input|
        params = {
          maxResults: input['maxResults'] || 50,
          startAt: input['startAt'] || 0
        }
        params['query'] = input['query'] if input['query'].present?

        response = get("https://api.atlassian.com/ex/jira/#{input['cloud_id']}/rest/api/3/user/search").
          params(params)

        { users: response }
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "users", type: "array", of: "object",
            properties: object_definitions["user"] }
        ]
      end
    },

    # Get all users (bulk)
    get_all_users: {
      description: "Get all <span class='provider'>users</span> from Jira site",

      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Jira Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Jira site" },
          { name: "maxResults", label: "Max Results", type: "integer", 
            optional: true, default: 50,
            hint: "Maximum number of users to return per page" }
        ]
      end,

      execute: lambda do |connection, input|
        params = {
          maxResults: input['maxResults'] || 50,
          startAt: 0
        }

        response = get("https://api.atlassian.com/ex/jira/#{input['cloud_id']}/rest/api/3/users/search").
          params(params)

        { users: response }
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "users", type: "array", of: "object",
            properties: object_definitions["user"] }
        ]
      end
    },

    # Get user groups
    get_user_groups: {
      description: "Get <span class='provider'>groups</span> that a user belongs to",

      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Jira Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Jira site" },
          { name: "accountId", label: "Account ID", optional: false,
            hint: "The account ID of the user" }
        ]
      end,

      execute: lambda do |connection, input|
        response = get("https://api.atlassian.com/ex/jira/#{input['cloud_id']}/rest/api/3/user/groups").
          params(accountId: input['accountId'])

        { groups: response }
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "groups", type: "array", of: "object",
            properties: [
              { name: "name", type: "string" },
              { name: "groupId", type: "string" },
              { name: "self", type: "string" }
            ]
          }
        ]
      end
    },

    # Find users assignable to projects
    find_assignable_users: {
      description: "Find <span class='provider'>users</span> assignable to projects",

      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Jira Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Jira site" },
          { name: "project", label: "Project Key or ID", optional: true,
            hint: "Project key or ID to find assignable users for" },
          { name: "query", label: "Query", optional: true,
            hint: "Query string to filter users" },
          { name: "maxResults", label: "Max Results", type: "integer", 
            optional: true, default: 50 }
        ]
      end,

      execute: lambda do |connection, input|
        params = {
          maxResults: input['maxResults'] || 50
        }
        params['project'] = input['project'] if input['project'].present?
        params['query'] = input['query'] if input['query'].present?

        response = get("https://api.atlassian.com/ex/jira/#{input['cloud_id']}/rest/api/3/user/assignable/search").
          params(params)

        { users: response }
      end,

      output_fields: lambda do |object_definitions|
        [
          { name: "users", type: "array", of: "object",
            properties: object_definitions["user"] }
        ]
      end
    }
  },

  # Triggers
  triggers: {
    # Note: Jira doesn't provide real-time webhooks through OAuth 2.0 apps easily
    # These would be polling-based triggers
    new_or_updated_user: {
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

  # Pick lists (for dropdown fields)
  pick_lists: {
    cloud_resources: lambda do |connection|
      resources = get("https://api.atlassian.com/oauth/token/accessible-resources")
      
      resources.map do |resource|
        [resource["name"], resource["id"]]
      end
    end
  }
}