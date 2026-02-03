{
  title: "Atlassian - Confluence Space API - https://developer.atlassian.com/cloud/confluence/rest/v2/api-group-space/#api-spaces-get",

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
          scope: "read:space:confluence",
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
    
    get_spaces: {
      title: "SPACES - Get spaces",
      description: "Returns all spaces. The results will be sorted by id ascending. The number of results is limited by the limit parameter and additional results (if available) will be available through the next URL present in the Link response header.",
      
      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Confluence Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Confluence site" }
        ]
      end,
      
      execute: lambda do |connection, input|
        get("https://api.atlassian.com/ex/confluence/#{input['cloud_id']}/wiki/api/v2/spaces")
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions["all_spaces_output"]
      end
    },
    
    get_space_by_id: {
      title: "SPACES - Get space by id",
      description: "Returns a specific space.",
      
      input_fields: lambda do |object_definitions|
        [
          { name: "cloud_id", label: "Confluence Site", 
            control_type: "select", pick_list: "cloud_resources",
            optional: false, hint: "Select your Confluence site" },
          { name: "space_id", label: "Space ID", 
            control_type: "text", type: "string",
            optional: false }
        ]
      end,
      
      execute: lambda do |connection, input|
        get("https://api.atlassian.com/ex/confluence/#{input['cloud_id']}/wiki/api/v2/spaces/#{input['space_id']}")
      end,
      
      output_fields: lambda do |object_definitions|
        object_definitions["space_detail_output"]
      end
    }
  },

  # Object definitions
  object_definitions: {
    
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
    
    all_spaces_output: {
      fields: lambda do |_connection, _config_fields|
        [
          {
            name: 'results',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'id', type: 'string' },
              { name: 'key', type: 'string' },
              { name: 'name', type: 'string' },
              { name: 'type', type: 'string' },
              { name: 'status', type: 'string' },
              { name: 'authorId', type: 'string' },
              { name: 'currentActiveAlias', type: 'string' },
              { name: 'createdAt', type: 'string' },
              { name: 'homepageId', type: 'string' },
              {
                name: 'description',
                type: 'object',
                properties: [
                  {
                    name: 'plain',
                    type: 'object',
                    properties: []
                  },
                  {
                    name: 'view',
                    type: 'object',
                    properties: []
                  }
                ]
              },
              {
                name: 'icon',
                type: 'object',
                properties: [
                  { name: 'path', type: 'string' },
                  { name: 'apiDownloadLink', type: 'string' }
                ]
              },
              {
                name: '_links',
                type: 'object',
                properties: [
                  { name: 'webui', type: 'string' }
                ]
              }
            ]
          },
          {
            name: '_links',
            type: 'object',
            properties: [
              { name: 'next', type: 'string' },
              { name: 'base', type: 'string' }
            ]
          }
        ]
      end
    },
    
    space_detail_output: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: 'id', type: 'string' },
          { name: 'key', type: 'string' },
          { name: 'name', type: 'string' },
          { name: 'type', type: 'string' },
          { name: 'status', type: 'string' },
          { name: 'authorId', type: 'string' },
          { name: 'createdAt', type: 'string' },
          { name: 'homepageId', type: 'string' },
          {
            name: 'description',
            type: 'object',
            properties: [
              {
                name: 'plain',
                type: 'object',
                properties: []
              },
              {
                name: 'view',
                type: 'object',
                properties: []
              }
            ]
          },
          {
            name: 'icon',
            type: 'object',
            properties: [
              { name: 'path', type: 'string' },
              { name: 'apiDownloadLink', type: 'string' }
            ]
          },
          {
            name: 'labels',
            type: 'object',
            properties: [
              {
                name: 'results',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'id', type: 'string' },
                  { name: 'name', type: 'string' },
                  { name: 'prefix', type: 'string' }
                ]
              },
              {
                name: 'meta',
                type: 'object',
                properties: [
                  { name: 'hasMore', type: 'boolean' },
                  { name: 'cursor', type: 'string' }
                ]
              },
              {
                name: '_links',
                type: 'object',
                properties: [
                  { name: 'self', type: 'string' }
                ]
              }
            ]
          },
          {
            name: 'properties',
            type: 'object',
            properties: [
              {
                name: 'results',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'id', type: 'string' },
                  { name: 'key', type: 'string' },
                  { name: 'createdAt', type: 'string' },
                  { name: 'createdBy', type: 'string' },
                  {
                    name: 'version',
                    type: 'object',
                    properties: [
                      { name: 'createdAt', type: 'string' },
                      { name: 'createdBy', type: 'string' },
                      { name: 'message', type: 'string' },
                      { name: 'number', type: 'integer' }
                    ]
                  }
                ]
              },
              {
                name: 'meta',
                type: 'object',
                properties: [
                  { name: 'hasMore', type: 'boolean' },
                  { name: 'cursor', type: 'string' }
                ]
              },
              {
                name: '_links',
                type: 'object',
                properties: [
                  { name: 'self', type: 'string' }
                ]
              }
            ]
          },
          {
            name: 'operations',
            type: 'object',
            properties: [
              {
                name: 'results',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'operation', type: 'string' },
                  { name: 'targetType', type: 'string' }
                ]
              },
              {
                name: 'meta',
                type: 'object',
                properties: [
                  { name: 'hasMore', type: 'boolean' },
                  { name: 'cursor', type: 'string' }
                ]
              },
              {
                name: '_links',
                type: 'object',
                properties: [
                  { name: 'self', type: 'string' }
                ]
              }
            ]
          },
          {
            name: 'permissions',
            type: 'object',
            properties: [
              {
                name: 'results',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'id', type: 'string' },
                  {
                    name: 'principal',
                    type: 'object',
                    properties: [
                      { name: 'type', type: 'string' },
                      { name: 'id', type: 'string' }
                    ]
                  },
                  {
                    name: 'operation',
                    type: 'object',
                    properties: [
                      { name: 'key', type: 'string' },
                      { name: 'targetType', type: 'string' }
                    ]
                  }
                ]
              },
              {
                name: 'meta',
                type: 'object',
                properties: [
                  { name: 'hasMore', type: 'boolean' },
                  { name: 'cursor', type: 'string' }
                ]
              },
              {
                name: '_links',
                type: 'object',
                properties: [
                  { name: 'self', type: 'string' }
                ]
              }
            ]
          },
          {
            name: '_links',
            type: 'object',
            properties: [
              { name: 'base', type: 'string' }
            ]
          }
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
    end
  }
}