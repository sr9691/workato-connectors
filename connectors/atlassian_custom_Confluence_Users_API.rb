{
  title: "Atlassian - Confluence Users API - https://developer.atlassian.com/cloud/confluence/rest/api-group-users/",

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
          scope: "read:confluence-user read:confluence-content.all write:confluence-content offline_access",
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
          { name: "email", label: "Email", type: "string" },
          { name: "publicName", label: "Public Name", type: "string" },
          { name: "displayName", label: "Display Name", type: "string" },
          { name: "profilePicture", label: "Profile Picture", type: "object", 
            properties: [
              { name: "path", type: "string" },
              { name: "width", type: "integer" },
              { name: "height", type: "integer" },
              { name: "isDefault", type: "boolean" }
            ]
          },
          { name: "isExternalCollaborator", label: "External Collaborator", type: "boolean" }
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
      description: "Get list of <span class='provider'>Confluence sites</span> accessible to the authenticated user",

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

    # Get current user
    get_current_user: {
      description: "Get the <span class='provider'>current authenticated user</span>",

      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Confluence Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Confluence site" }
        ]
      end,

      execute: lambda do |connection, input|
        get("https://api.atlassian.com/ex/confluence/#{input['cloud_id']}/wiki/rest/api/user/current")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["user"]
      end
    },

    # Get user by account ID
    get_user: {
      description: "Get <span class='provider'>user details</span> by account ID",

      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Confluence Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Confluence site" },
          { name: "accountId", label: "Account ID", optional: false,
            hint: "The account ID of the user" }
        ]
      end,

      execute: lambda do |connection, input|
        get("https://api.atlassian.com/ex/confluence/#{input['cloud_id']}/wiki/rest/api/user").
          params(accountId: input['accountId'])
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["user"]
      end
    },

    # Get bulk users
    get_bulk_users: {
      description: "Get multiple <span class='provider'>users</span> by account IDs",

      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Confluence Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Confluence site" },
          { name: "accountIds", label: "Account IDs", optional: false,
            hint: "Comma-separated list of account IDs (max 200)" },
          { name: "limit", label: "Limit", type: "integer", 
            optional: true, default: 200,
            hint: "Maximum number of users to return (default: 200)" }
        ]
      end,

      execute: lambda do |connection, input|
        params = { accountId: input['accountIds'] }
        params[:limit] = input['limit'] if input['limit'].present?

        response = get("https://api.atlassian.com/ex/confluence/#{input['cloud_id']}/wiki/rest/api/user/bulk").
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

    # Get anonymous user
    get_anonymous_user: {
      description: "Get the <span class='provider'>anonymous user</span> information",

      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Confluence Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Confluence site" }
        ]
      end,

      execute: lambda do |connection, input|
        get("https://api.atlassian.com/ex/confluence/#{input['cloud_id']}/wiki/rest/api/user/anonymous")
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["user"]
      end
    },

    # Get user by email
    get_user_by_email: {
      description: "Get <span class='provider'>user details</span> by email address",

      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Confluence Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Confluence site" },
          { name: "email", label: "Email Address", optional: false,
            hint: "The email address of the user" }
        ]
      end,

      execute: lambda do |connection, input|
        get("https://api.atlassian.com/ex/confluence/#{input['cloud_id']}/wiki/rest/api/user/email").
          params(email: input['email'])
      end,

      output_fields: lambda do |object_definitions|
        object_definitions["user"]
      end
    },

    # Get multiple users by email
    get_bulk_users_by_email: {
      description: "Get multiple <span class='provider'>users</span> by email addresses",

      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Confluence Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Confluence site" },
          { name: "emails", label: "Email Addresses", optional: false,
            hint: "Comma-separated list of email addresses (max 200)" },
          { name: "limit", label: "Limit", type: "integer", 
            optional: true, default: 200,
            hint: "Maximum number of users to return (default: 200)" }
        ]
      end,

      execute: lambda do |connection, input|
        params = { email: input['emails'] }
        params[:limit] = input['limit'] if input['limit'].present?

        response = get("https://api.atlassian.com/ex/confluence/#{input['cloud_id']}/wiki/rest/api/user/email/bulk").
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
    # Polling-based trigger for users
    new_or_updated_user: {
      description: "Triggers when a <span class='provider'>user</span> is created or updated in Confluence",
      
      type: :paging_desc,

      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Confluence Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Confluence site" },
          { name: "since", label: "When first started, this recipe should pick up events from", 
            type: "timestamp", optional: true,
            hint: "Leave blank to get users from now onwards" }
        ]
      end,

      poll: lambda do |connection, input, page|
        page ||= 0
        page_size = 50

        # Note: Confluence doesn't have a direct "list all users" endpoint
        # This is a simplified example - you may need to adjust based on your needs
        # You might need to use a different approach like getting users from spaces or pages
        
        # For this example, we'll use the bulk endpoint with known account IDs
        # In production, you'd need to maintain a list of account IDs or use a different strategy
        
        {
          events: [],
          next_page: nil
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