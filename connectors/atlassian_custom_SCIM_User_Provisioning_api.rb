{
  title: 'Atlassian - SCIM User Provisioning API - https://developer.atlassian.com/cloud/admin/user-provisioning/rest',
  
  connection: {
    fields: [
      {
        name: 'api_key',
        label: 'API Key',
        hint: 'Generated at https://admin.atlassian.com/. Go to Security → User security → Identity providers. Create a "Generic", "Custom" or similar',
        optional: false,
      },
      {
        name: 'directory_id',
        label: 'Directory ID',
        hint: 'Directory ID is provided when API Key is generated. Along with the key, a url will be provided and directory ID will be a part of this URL. Pattern: https://api.atlassian.com/scim/directory/*DIRECTORY ID*',
        optional: false,
      }
    ],

    authorization: {
      type: 'custom_auth', #Set to custom_auth

      apply: lambda do |connection|
        headers(
          "Authorization": "Bearer #{connection["api_key"]}",
          "Accept": "application/json"
        )
      end
    },

    base_uri: lambda do |connection|
      "https://api.atlassian.com/scim/directory/#{connection['directory_id']}"
    end

  },

  test: lambda do |connection|
      get("https://api.atlassian.com/scim/directory/#{connection['directory_id']}/Users")
  end,
  
  
    actions: {
      
      users_all: {
        title: "USERS - Get all users",
        subtitle: "Get a list of all SCIM users",
        
        input_fields: lambda do |_object_definitions|
          [
            {
               name: "startIndex",
               label: "Start index",
               type: "integer",
               optional: true,
               hint: "1-based index of the first result to return"
             },
             {
               name: "count",
               label: "Count",
               type: "integer",
               optional: true,
               hint: "Maximum number of users to return"
            }
          ]
        end,

        execute: lambda do |connection, input|
          params = {}

          params[:startIndex] = input["startIndex"] if input["startIndex"].present?
          params[:count]      = input["count"]      if input["count"].present?
          
          get("/scim/directory/#{connection['directory_id']}/Users").params(params)
        end,

        output_fields: lambda do |object_definitions|
          object_definitions[:all_users_output]
        end
    },
      
    users_all_auto_paginated: {
      title: "USERS - Get all users (auto-paginated)",
      subtitle: "Fetches all SCIM users across all pages automatically",
  
      input_fields: lambda do |_object_definitions|
        [
          {
            name: "page_size",
            label: "Page size",
            type: "integer",
            optional: true,
            default: 100,
            hint: "Number of users to fetch per request (SCIM count parameter)"
          }
        ]
      end,
  
      execute: lambda do |connection, input|
        users = []
  
        start_index = 1
        page_size   = input["page_size"] || 100
        total       = nil
  
        loop do
          response =
            get("/scim/directory/#{connection['directory_id']}/Users")
              .params(
                startIndex: start_index,
                count: page_size
              )
  
          # SCIM puts users in `Resources`
          page_users = response["Resources"] || []
          users.concat(page_users)
  
          total ||= response["totalResults"].to_i
  
          # Stop when we've fetched everything
          break if users.size >= total || page_users.empty?
  
          # SCIM pagination is 1-based
          start_index += page_size.to_i
        end
  
        {
          schemas: [],
          totalResults: users.size,
          startIndex: 1,
          itemsPerPage: users.size,
          Resources: users
        }
      end,
  
      output_fields: lambda do |object_definitions|
          object_definitions[:all_users_output]
      end
    },

      user_by_id: {
        title: "USERS - Get a user by ID",
        subtitle: "Get a user by ID",

        input_fields: lambda do |object_definitions|
          [
            {
              name: "userId",
              label: "User ID",
              type: "string",
              optional: false
            },
          ]
        end,

        execute: lambda do |connection, input|
          get("/scim/directory/#{connection['directory_id']}/Users/#{input['userid']}")
        end,

        output_fields: lambda do |object_definitions|
          object_definitions[:user_by_id_output]
        end
    },

    create_user: {
        title: "USERS - Create user",
        subtitle: "Create user",

        input_fields: lambda do |object_definitions|
          object_definitions[:create_user_input]
        end,

        execute: lambda do |connection, input|
          post("/scim/directory/#{connection['directory_id']}/Users", input)
        end,

        output_fields: lambda do |object_definitions|
          object_definitions[:create_user_output]
        end
    },
    delete_user: {
        title: "USERS - Delete user",
        subtitle: "Delete user",

        input_fields: lambda do |object_definitions|
          [
            {
              name: "userId",
              label: "User ID",
              type: "string",
              optional: false
            },
          ]
        end,

        execute: lambda do |connection, input|
          delete("/scim/directory/#{connection['directory_id']}/Users/#{input['userId']}")
        end,

        output_fields: lambda do |object_definitions|
          object_definitions[:create_user_output]
        end
    },
    
      groups_all: {
        title: "GROUPS - Get all users",
        subtitle: "Get a list of all SCIM groups",
        
        input_fields: lambda do |_object_definitions|
          [
            {
               name: "startIndex",
               label: "Start index",
               type: "integer",
               optional: true,
               hint: "1-based index of the first result to return"
             },
             {
               name: "count",
               label: "Count",
               type: "integer",
               optional: true,
               hint: "Maximum number of users to return"
            }
          ]
        end,

        execute: lambda do |connection, input|
          params = {}

          params[:startIndex] = input["startIndex"] if input["startIndex"].present?
          params[:count]      = input["count"]      if input["count"].present?
          
          get("/scim/directory/#{connection['directory_id']}/Groups").params(params)
        end,

        output_fields: lambda do |object_definitions|
          object_definitions[:all_groups_output]
        end
    },
      
    groups_all_auto_paginated: {
      title: "GROUPS - Get goups (auto-paginated)",
      subtitle: "Fetches all SCIM groups across all pages automatically",
  
      input_fields: lambda do |_object_definitions|
        [
          {
            name: "page_size",
            label: "Page size",
            type: "integer",
            optional: true,
            default: 100,
            hint: "Number of groups to fetch per request (SCIM count parameter)"
          }
        ]
      end,
  
      execute: lambda do |connection, input|
        groups = []
  
        start_index = 1
        page_size   = input["page_size"] || 100
        total       = nil
  
        loop do
          response =
            get("/scim/directory/#{connection['directory_id']}/Groups")
              .params(
                startIndex: start_index,
                count: page_size
              )
  
          # SCIM puts users in `Resources`
          page_groups = response["Resources"] || []
          groups.concat(page_groups)
  
          total ||= response["totalResults"].to_i
  
          # Stop when we've fetched everything
          break if groups.size >= total || page_groups.empty?
  
          # SCIM pagination is 1-based
          start_index += page_size.to_i
        end
  
        {
          schemas: [],
          totalResults: groups.size,
          startIndex: 1,
          itemsPerPage: groups.size,
          Resources: groups
        }
      end,
  
      output_fields: lambda do |object_definitions|
          object_definitions[:all_groups_output]
      end
    },
  },
  
  ################################
  # OBJECT DEFINITIONS
  ################################
  object_definitions: {
    all_users_output: {
      fields: lambda do |_connection, _config_fields|
        [
          {
            name: 'schemas',
            type: 'array',
            of: 'string'
          },
          { name: 'totalResults', type: 'integer' },
          { name: 'startIndex', type: 'integer' },
          { name: 'itemsPerPage', type: 'integer' },
          {
            name: 'Resources',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'schemas', type: 'array', of: 'string' },
              { name: 'userName', type: 'string' },
              {
                name: 'emails',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'value', type: 'string' },
                  { name: 'type', type: 'string' },
                  { name: 'primary', type: 'boolean', control_type: "checkbox" }
                ]
              },
              { name: 'id', type: 'string' },
              { name: 'externalId', type: 'string' },
              {
                name: 'name',
                type: 'object',
                properties: [
                  { name: 'formatted', type: 'string' },
                  { name: 'familyName', type: 'string' },
                  { name: 'givenName', type: 'string' },
                  { name: 'middleName', type: 'string' },
                  { name: 'honorificPrefix', type: 'string' },
                  { name: 'honorificSuffix', type: 'string' }
                ]
              },
              { name: 'displayName', type: 'string' },
              { name: 'nickName', type: 'string' },
              { name: 'title', type: 'string' },
              { name: 'preferredLanguage', type: 'string' },
              { name: 'department', type: 'string' },
              { name: 'organization', type: 'string' },
              { name: 'timezone', type: 'string' },
              {
                name: 'phoneNumbers',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'value', type: 'string' },
                  { name: 'type', type: 'string' },
                  { name: 'primary', type: 'boolean', control_type: "checkbox" }
                ]
              },
              {
                name: 'meta',
                type: 'object',
                properties: [
                  { name: 'resourceType', type: 'string' },
                  { name: 'location', type: 'string' },
                  { name: 'lastModified', type: 'string' },
                  { name: 'created', type: 'string' }
                ]
              },
              {
                name: 'groups',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'type', type: 'string' },
                  { name: 'value', type: 'string' },
                  { name: 'display', type: 'string' },
                  { name: '$ref', type: 'string' }
                ]
              },
              {
                name: 'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User',
                type: 'object',
                properties: [
                  { name: 'organization', type: 'string' },
                  { name: 'department', type: 'string' }
                ]
              },
              {
                name: 'urn:scim:schemas:extension:atlassian-external:1.0',
                type: 'object',
                properties: [
                  { name: 'atlassianAccountId', type: 'string' }
                ]
              },
              { name: 'active', type: 'boolean', control_type: "checkbox" }
            ]
          }
        ]
      end
    },
    
    user_by_id_output: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: 'schemas', type: 'array', of: 'string' },
          { name: 'userName', type: 'string' },
          {
            name: 'emails',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'value', type: 'string' },
              { name: 'type', type: 'string' },
              { name: 'primary', type: 'boolean', control_type: "checkbox" }
            ]
          },
          { name: 'id', type: 'string' },
          { name: 'externalId', type: 'string' },
          {
            name: 'name',
            type: 'object',
            properties: [
              { name: 'formatted', type: 'string' },
              { name: 'familyName', type: 'string' },
              { name: 'givenName', type: 'string' },
              { name: 'middleName', type: 'string' },
              { name: 'honorificPrefix', type: 'string' },
              { name: 'honorificSuffix', type: 'string' }
            ]
          },
          { name: 'displayName', type: 'string' },
          { name: 'nickName', type: 'string' },
          { name: 'title', type: 'string' },
          { name: 'preferredLanguage', type: 'string' },
          { name: 'department', type: 'string' },
          { name: 'organization', type: 'string' },
          { name: 'timezone', type: 'string' },
          {
            name: 'phoneNumbers',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'value', type: 'string' },
              { name: 'type', type: 'string' },
              { name: 'primary', type: 'boolean', control_type: "checkbox" }
            ]
          },
          {
            name: 'meta',
            type: 'object',
            properties: [
              { name: 'resourceType', type: 'string' },
              { name: 'location', type: 'string' },
              { name: 'lastModified', type: 'string' },
              { name: 'created', type: 'string' }
            ]
          },
          {
            name: 'groups',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'type', type: 'string' },
              { name: 'value', type: 'string' },
              { name: 'display', type: 'string' },
              { name: '$ref', type: 'string' }
            ]
          },
          {
            name: 'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User',
            type: 'object',
            properties: [
              { name: 'organization', type: 'string' },
              { name: 'department', type: 'string' }
            ]
          },
          {
            name: 'urn:scim:schemas:extension:atlassian-external:1.0',
            type: 'object',
            properties: [
              { name: 'atlassianAccountId', type: 'string' }
            ]
          },
          { name: 'active', type: 'boolean', control_type: "checkbox" }
        ]
      end
    },
    create_user_input: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: 'userName', type: 'string' },
          {
            name: 'emails',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'value', type: 'string' },
              { name: 'type', type: 'string' },
              {
                name: 'primary',
                type: 'boolean',
                control_type: 'select',
                pick_list: [
                  ['True', true],
                  ['False', false]
                ],
                toggle_hint: 'Select from list',
                toggle_field: {
                  name: 'primary',
                  type: 'boolean',
                  control_type: 'text',
                  toggle_hint: 'Use custom value',
                  hint: 'Enter a boolean value or use a datapill'
                }
              },
            ]
          },
          {
            name: 'name',
            type: 'object',
            properties: [
              { name: 'formatted', type: 'string' },
              { name: 'familyName', type: 'string' },
              { name: 'givenName', type: 'string' },
              { name: 'middleName', type: 'string' },
              { name: 'honorificPrefix', type: 'string' },
              { name: 'honorificSuffix', type: 'string' }
            ]
          },
          { name: 'displayName', type: 'string' },
          { name: 'nickName', type: 'string' },
          { name: 'title', type: 'string' },
          { name: 'preferredLanguage', type: 'string' },
          { name: 'department', type: 'string' },
          { name: 'organization', type: 'string' },
          { name: 'timezone', type: 'string' },
          {
            name: 'phoneNumbers',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'value', type: 'string' },
              { name: 'type', type: 'string' },
              {
                name: 'primary',
                type: 'boolean',
                control_type: 'select',
                pick_list: [
                  ['True', true],
                  ['False', false]
                ],
                toggle_hint: 'Select from list',
                toggle_field: {
                  name: 'primary',
                  type: 'boolean',
                  control_type: 'text',
                  toggle_hint: 'Use custom value',
                  hint: 'Enter a boolean value or use a datapill'
                }
              },
            ]
          },
          {
            name: 'active',
            type: 'boolean',
            control_type: 'select',
            pick_list: [
              ['True', true],
              ['False', false]
            ],
            toggle_hint: 'Select from list',
            toggle_field: {
              name: 'active',
              type: 'boolean',
              control_type: 'text',
              toggle_hint: 'Use custom value',
              hint: 'Enter a boolean value or use a datapill'
            }
          },
        ]
      end
    },
    create_user_output: {
      fields: lambda do |_connection, _config_fields|
        [
          {
            name: 'schemas',
            type: 'array',
            of: 'string'
          },
          { name: 'userName', type: 'string' },
          {
            name: 'emails',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'value', type: 'string' },
              { name: 'type', type: 'string' },
              { name: 'primary', type: 'boolean', control_type: "checkbox" }
            ]
          },
          { name: 'id', type: 'string' },
          { name: 'externalId', type: 'string' },
          {
            name: 'name',
            type: 'object',
            properties: [
              { name: 'formatted', type: 'string' },
              { name: 'familyName', type: 'string' },
              { name: 'givenName', type: 'string' },
              { name: 'middleName', type: 'string' },
              { name: 'honorificPrefix', type: 'string' },
              { name: 'honorificSuffix', type: 'string' }
            ]
          },
          { name: 'displayName', type: 'string' },
          { name: 'nickName', type: 'string' },
          { name: 'title', type: 'string' },
          { name: 'preferredLanguage', type: 'string' },
          { name: 'department', type: 'string' },
          { name: 'organization', type: 'string' },
          { name: 'timezone', type: 'string' },
          {
            name: 'phoneNumbers',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'value', type: 'string' },
              { name: 'type', type: 'string' },
              { name: 'primary', type: 'boolean', control_type: "checkbox" }
            ]
          },
          {
            name: 'meta',
            type: 'object',
            properties: [
              { name: 'resourceType', type: 'string' },
              { name: 'location', type: 'string' },
              { name: 'lastModified', type: 'string' },
              { name: 'created', type: 'string' }
            ]
          },
          {
            name: 'groups',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'type', type: 'string' },
              { name: 'value', type: 'string' },
              { name: 'display', type: 'string' },
              { name: '$ref', type: 'string' }
            ]
          },
          {
            name: 'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User',
            type: 'object',
            properties: [
              { name: 'organization', type: 'string' },
              { name: 'department', type: 'string' }
            ]
          },
          {
            name: 'urn:scim:schemas:extension:atlassian-external:1.0',
            type: 'object',
            properties: [
              { name: 'atlassianAccountId', type: 'string' }
            ]
          },
          { name: 'active', type: 'boolean', control_type: "checkbox" }
        ]
      end
    },
    all_groups_output: {
      fields: lambda do |_connection, _config_fields|
        [
          {
            name: 'schemas',
            type: 'array',
            of: 'string'
          },
          { name: 'totalResults', type: 'integer' },
          { name: 'startIndex', type: 'integer' },
          { name: 'itemsPerPage', type: 'integer' },
          {
            name: 'Resources',
            type: 'array',
            of: 'object',
            properties: [
              {
                name: 'schemas',
                type: 'array',
                of: 'string'
              },
              { name: 'id', type: 'string' },
              { name: 'externalId', type: 'string' },
              { name: 'displayName', type: 'string' },
              {
                name: 'members',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'type', type: 'string' },
                  { name: 'value', type: 'string' },
                  { name: 'display', type: 'string' },
                  { name: '$ref', type: 'string' }
                ]
              },
              {
                name: 'meta',
                type: 'object',
                properties: [
                  { name: 'resourceType', type: 'string' },
                  { name: 'location', type: 'string' },
                  { name: 'lastModified', type: 'string' },
                  { name: 'created', type: 'string' }
                ]
              }
            ]
          }
        ]
      end
    }
  }
}