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
    }
  },
  
  ################################
  # OBJECT DEFINITIONS
  ################################
  object_definitions: {
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
              { name: 'primary', type: 'boolean', control_type: "checkbox" }
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
              { name: 'primary', type: 'boolean', control_type: "checkbox" }
            ]
          },
          { name: 'active', type: 'boolean', control_type: "checkbox" }
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
    }
  }
}