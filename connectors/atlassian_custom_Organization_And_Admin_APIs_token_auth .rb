{
  title: 'Organization & Admin APIs (Auth Token) - https://developer.atlassian.com/cloud/admin/organization/rest/intro/#auth',
  
  connection: {
    fields: [
      {
        name: 'api_key',
        label: 'API Key',
        control_type: 'password',
        hint: 'Generated at https://admin.atlassian.com/. Go to Security → User security → Identity providers. Create a "Generic", "Custom" or similar',
        optional: false,
      },
    ],

    authorization: {
      type: 'custom_auth', 

      apply: lambda do |connection|
        headers(
          "Authorization": "Bearer #{connection["api_key"]}",
          "Accept": "application/json"
        )
      end
    },

    base_uri: lambda do |connection|
      "https://api.atlassian.com"
    end

  },

  test: lambda do |connection|
      get("/admin/v1/orgs")
  end,
  
  
    actions: {
      
      get_all_users: {
        title: "USERS - Get all users",
        subtitle: "Get a list of all users",
        
        input_fields: lambda do |_object_definitions|
          [
            {   
               name: "organization_id", 
               label: "Organization", 
               control_type: "select", 
               pick_list: "organization_list",
               optional: false 
            },
            { 
               name: "directory_id", 
               label: "Directory", 
               control_type: "select", 
               pick_list: "directories_list",
               pick_list_params: { organization_id: "organization_id" },
               optional: false,
               hint: "Select an organization first"
            }
          ]
        end,

        execute: lambda do |connection, input|
          get("/admin/v2/orgs/#{input['organization_id']}/directories/#{input['directory_id']}/users")
        end,

        output_fields: lambda do |object_definitions|
          object_definitions[:get_all_users_output]
        end
    },
      
    
  },
  
  ################################
  # OBJECT DEFINITIONS
  ################################
  object_definitions: {
    get_all_users_output: {
      fields: lambda do |_connection, _config_fields|
        [
          {
            name: 'data',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'accountId', type: 'string' },
              { name: 'accountType', type: 'string' },
              { name: 'status', type: 'string' },
              { name: 'accountStatus', type: 'string' },
              { name: 'membershipStatus', type: 'string' },
              { name: 'addedToOrg', type: 'string' },
              { name: 'name', type: 'string' },
              { name: 'nickname', type: 'string' },
              { name: 'email', type: 'string' },
              { name: 'emailVerified', type: 'boolean' },
              { name: 'claimStatus', type: 'string' },
              {
                name: 'platformRoles',
                type: 'array',
                of: 'string'
              },
              { name: 'picture', type: 'string' },
              { name: 'avatar', type: 'string' },
              { name: 'managementSource', type: 'string' },
              { name: 'mfaEnabled', type: 'boolean' },
              { name: 'jobTitle', type: 'string' },
              { name: 'department', type: 'string' },
              { name: 'organization', type: 'string' },
              { name: 'location', type: 'string' },
              { name: 'timeZone', type: 'string' },
              {
                name: 'counts',
                type: 'object',
                properties: [
                  { name: 'resources', type: 'integer' }
                ]
              },
              {
                name: 'links',
                type: 'object',
                properties: [
                  { name: 'self', type: 'string' }
                ]
              }
            ]
          },
          {
            name: 'links',
            type: 'object',
            properties: [
              { name: 'self', type: 'string' },
              { name: 'prev', type: 'string' },
              { name: 'next', type: 'string' }
            ]
          }
        ]
      end
    }

  },
  
  pick_lists: {
    organization_list: lambda do |connection|
    
      response = get("https://api.atlassian.com/admin/v1/orgs")
    
      response["data"].map do |org|
        [org["attributes"]["name"], org["id"]]
      end
    end,
    
    directories_list: lambda do |connection, organization_id:|
    # organization_id is passed as a parameter from the input field
      response = get("https://api.atlassian.com/admin/v2/orgs/#{organization_id}/directories")
    
      response["data"].map do |directory|
        [directory["name"], directory["directoryId"]]
      end
    end,
  }
}