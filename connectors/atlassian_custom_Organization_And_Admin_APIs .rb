{
  title: 'Atlassian - Organization & Admin APIs - https://developer.atlassian.com/cloud/admin/',
  

  connection: {
    fields: [
      {
        name: 'atlassian_domain',
        label: 'Atlassian subdomain',
        control_type: 'subdomain',
        url: '.atlassian.net',
        hint: 'Provide your atlassian app sub-domain: http://{{SUB DOMAIN}}.atlassian.net',
        optional: false,
      },
      {
        name: 'api_key',
        label: 'API Key',
        hint: 'Generated at https://admin.atlassian.com/. Go to Security → User security → Identity providers. Create a "Generic", "Custom" or similar',
        optional: false,
      },
      {
        name: 'email',
        label: 'Email',
        hint: 'Same login email from the user that generated the api key',
        optional: false,
      }
    ],

    authorization: {
      type: 'basic_auth',
      apply: lambda do |connection|
        user(connection['email'])
        password(connection['api_key'])
      end
    },

    base_uri: lambda do |connection|
      "https://#{connection["atlassian_domain"]}.atlassian.net"
    end

  },

  test: lambda do |connection|
      get("/rest/api/3/groups/picker")
  end,
  
  
    actions: {

      user_by_id: {
        title: "Get groupId",
        subtitle: "Get a user by ID",

        #input_fields: lambda do |object_definitions|
        #  [
        #    {
        #      name: "userId",
        #      label: "User ID",
        #      type: "string",
        #      optional: false
        #    },
        #  ]
        #end,

        execute: lambda do |connection, input|
          get("/rest/api/3/groups/picker")
        end,

        #output_fields: lambda do |object_definitions|
        #  object_definitions[:user_by_id_output]
        #end
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
              { name: 'primary', type: 'boolean' }
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
              { name: 'primary', type: 'boolean' }
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
          { name: 'active', type: 'boolean' }
        ]
      end
    }
  }
}