{
  title: 'Atlassian (Admin + Jira)',
  description: 'Unified connector for Atlassian Organization Admin API (invite users) ' \
               'and Jira Cloud REST API (get user).',
  logo: 'https://ww1.freelogodesign.org/file/app/article/350/thumb_atlassian.png',

  # ===========================================================================
  # CONNECTION
  # ===========================================================================
  #
  # WHY TWO CREDENTIALS?
  #
  # These two APIs belong to different Atlassian platform layers and use
  # different authentication schemes. They cannot share a single credential:
  #
  # 1. Atlassian ADMIN API  →  POST /admin/v2/orgs/{orgId}/users/invite
  #    Auth: Bearer token
  #    Key type: Atlassian Admin API Key (organization-scoped)
  #    Generate at: https://admin.atlassian.com → Settings → API keys
  #    Notes: OAuth 2.0 is NOT available for this endpoint — it is not listed
  #           in the Admin API's OAuth scope table. An API key is the only
  #           supported auth method.
  #
  # 2. Jira Cloud REST API  →  GET /rest/api/3/user
  #    Auth: HTTP Basic (Base64 of "email:api_token")
  #    Key type: Atlassian Account API Token (user-scoped)
  #    Generate at: https://id.atlassian.com/manage-profile/security/api-tokens
  #    Notes: OAuth 2.0 (3LO) is also supported by Jira, but since the Admin
  #           API above cannot use OAuth, we use Basic auth + API token here
  #           so both actions share one simple connector with no OAuth flow.
  #
  # ===========================================================================

  connection: {
    fields: [
      # --- Admin API credentials ---
      {
        name: 'admin_api_key',
        label: 'Admin API Key',
        hint: 'An Atlassian Admin API Key (Bearer token). ' \
              'Generate one at admin.atlassian.com → Settings → API keys. ' \
              'Required for the "Invite users" action.',
        control_type: 'password',
        optional: false
      },
      {
        name: 'org_id',
        label: 'Organization ID',
        hint: 'Your Atlassian organization ID. ' \
              'Visible in the URL: admin.atlassian.com/o/{orgId}/overview.',
        optional: false
      },

      # --- Jira API credentials ---
      {
        name: 'jira_subdomain',
        label: 'Jira subdomain',
        hint: 'The subdomain of your Jira site, e.g. "mycompany" ' \
              'for mycompany.atlassian.net.',
        optional: false
      },
      {
        name: 'jira_email',
        label: 'Jira user email',
        hint: 'The email address associated with your Atlassian account. ' \
              'Used for Jira Basic auth.',
        optional: false
      },
      {
        name: 'jira_api_token',
        label: 'Jira API Token',
        hint: 'An Atlassian Account API token (NOT the same as the Admin API Key). ' \
              'Generate one at id.atlassian.com → Security → API tokens. (https://id.atlassian.com/manage-profile/security/api-tokens)' \
              'Required for the "Get user" action.',
        control_type: 'password',
        optional: false
      }
    ],

    authorization: {
      # We use custom_auth because the two actions call different base URLs
      # and use different auth headers. Each action builds its own headers
      # manually (see execute blocks below), so nothing global is applied here.
      type: 'custom_auth',
      apply: lambda do |_connection|
        # Intentionally empty — auth headers are applied per-action below.
      end
    },

    base_uri: lambda do |_connection|
      # Fallback base URI (Admin API). Jira calls use an absolute URL.
      'https://api.atlassian.com'
    end
  },

  # ===========================================================================
  # CONNECTION TEST
  # ===========================================================================
  # Validates the Admin API key + org_id by fetching the org resource.
  test: lambda do |connection|
    get("/admin/v1/orgs/#{connection['org_id']}")
      .headers('Authorization' => "Bearer #{connection['admin_api_key']}")
  end,

  # ===========================================================================
  # ACTIONS
  # ===========================================================================
  actions: {

    # --------------------------------------------------------------------------
    # ACTION 1 — Invite users to organization
    # POST https://api.atlassian.com/admin/v2/orgs/{orgId}/users/invite
    # Docs: https://developer.atlassian.com/cloud/admin/organization/rest/
    #         api-group-users/#api-v2-orgs-orgid-users-invite-post
    # Auth: Bearer {Admin API Key}
    # --------------------------------------------------------------------------
    invite_users: {
      title: 'USERS (Org & Admin) - Invite users to organization',
      subtitle: 'Send email invitations to join your Atlassian organization.',
      description: 'Invites one or more users by email. Optionally assigns ' \
                   'product roles and groups. Requires at least one paid ' \
                   'subscription on the org.',

      input_fields: lambda do |_object_definitions|
        [
          {
            name: 'emails',
            label: 'Email addresses',
            hint: 'Comma-separated list of emails to invite ' \
                  '(e.g. alice@example.com, bob@example.com).',
            optional: false
          },
          {
            name: 'send_notification',
            label: 'Send email notification?',
            control_type: 'text',
            type: 'boolean',
            default: true,
            optional: true,
            render_input: 'boolean_conversion',
            parse_output: 'boolean_conversion',
            toggle_hint: 'Select from option list',
            toggle_field: {
              name: 'send_notification',
              label: 'Send email notification?',
              type: 'boolean',
              control_type: 'text',
              render_input: 'boolean_conversion',
              parse_output: 'boolean_conversion',
              toggle_hint: 'Use data pill or formula',
              hint: 'Map a boolean data pill or formula. Resolves to true or false.',
              optional: true
            }
          },
          {
            name: 'notification_text',
            label: 'Custom notification message',
            hint: 'Optional personal message to include in the invitation email.',
            control_type: 'text-area',
            optional: true
          },
          {
            name: 'permission_rules',
            label: 'Permission rules',
            hint: 'Assign product/site roles to invited users.',
            type: 'array',
            of: 'object',
            optional: false,
            properties: [
              {
                name: 'resource',
                label: 'Resource ARI',
                hint: 'e.g. ari:cloud:jira::site/35273b54-3f06-40d2-880f-dd28cf8daafa',
                optional: false
              },
              {
                name: 'role',
                label: 'Role',
                hint: 'e.g. atlassian/user or atlassian/guest',
                optional: false
              }
            ]
          },
          {
            name: 'additional_groups',
            label: 'Additional groups',
            hint: 'Add one group ID per row.',
            type: 'array',
            of: 'string',
            optional: true
          }
        ]
      end,

      execute: lambda do |connection, input|
        emails_array = input['emails']
                         .split(',')
                         .map(&:strip)
                         .reject(&:empty?)

        perm_rules = (input['permission_rules'] || []).map do |r|
          { 'resource' => r['resource'], 'role' => r['role'] }
        end

        groups_array = input['additional_groups'] || []

        payload = {
          'emails'           => emails_array,
          'sendNotification' => input['send_notification'].nil? ? true : input['send_notification']
        }
        payload['permissionRules']  = perm_rules   if perm_rules.present?
        payload['additionalGroups'] = groups_array if groups_array.present?
        payload['notificationText'] = input['notification_text'] if input['notification_text'].present?

        post("/admin/v2/orgs/#{connection['org_id']}/users/invite", payload)
          .headers(
            'Authorization' => "Bearer #{connection['admin_api_key']}",
            'Content-Type'  => 'application/json',
            'Accept'        => 'application/json'
          )
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:invite_user_output]
      end,
    },
    
    delete_user: {
       title: "USERS (Org & Admin) - Delete user",
       subtitle: "Delete people to your organization.",
       
       input_fields: lambda do |_object_definitions|
         [
           #{   
           #  name: "organization_id", 
           #  label: "Organization", 
           #  control_type: "select", 
           #  pick_list: "organization_list",
           #  optional: false 
           #},
           { 
             name: "directory_id", 
             label: "Directory", 
             control_type: "select", 
             pick_list: "directories_list",
             optional: false,
             hint: "Select an organization first"
           },
           {   
             name: "user_id", 
             label: "User ID", 
             control_type: "text",
             type: 'string',
             optional: false 
           }
          ]
        end,
        
        execute: lambda do |connection, input|
          delete("/admin/v2/orgs/#{connection['org_id']}/directories/#{input['directory_id']}/users/#{input['user_id']}")
          .headers(
            'Authorization' => "Bearer #{connection['admin_api_key']}",
            'Content-Type'  => 'application/json',
            'Accept'        => 'application/json'
          )
        end,

        # No output field, just 204 status when suceeded
    },
    
    get_org_users: {
      title: 'USERS (Org & Admin) - Get all users in organization directory',
      subtitle: 'Fetches all users from a directory, handling pagination automatically.',
      description: 'Calls GET /admin/v2/orgs/{orgId}/directories/{directoryId}/users ' \
                   'repeatedly until all pages are collected, then returns the full list.',
    
      input_fields: lambda do |_object_definitions|
        [
          {
            name: 'directory_id',
            label: 'Directory',
            hint: 'The directory to fetch users from.',
            control_type: 'select',
            pick_list: 'directories_list',
            optional: false
          }
        ]
      end,
    
      execute: lambda do |connection, input|
        base_url   = 'https://api.atlassian.com'
        auth_header = { 'Authorization' => "Bearer #{connection['admin_api_key']}" }
        endpoint   = "/admin/v2/orgs/#{connection['org_id']}/directories/#{input['directory_id']}/users"
    
        all_users = []
        cursor    = nil
    
        # Loop until there is no next cursor
        loop do
          params = {}
          params['cursor'] = cursor if cursor.present?
    
          response = get("#{base_url}#{endpoint}")
                       .params(params)
                       .headers(auth_header)
    
          all_users.concat(response['data'] || [])
    
          # links.next contains the full next-page URL; extract cursor from it
          next_url = response.dig('links', 'next')
          break if next_url.blank?
    
          # Parse cursor value out of the next URL query string
          cursor = next_url.split('cursor=').last&.split('&')&.first
          break if cursor.blank?
        end
    
        { 'data' => all_users, 'total' => all_users.length }
      end,
    
      output_fields: lambda do |object_definitions|
        object_definitions['get_all_organization_users_output']
      end,
    
    },
    
        get_user_last_active_dates: {
      title: 'USERS (Org & Admin) - Get user last active dates',
      subtitle: 'Returns the last active dates for a user across Atlassian products.',
      description: 'Calls GET /admin/v1/orgs/{orgId}/directory/users/{accountId}/last-active-dates.',
    
      input_fields: lambda do |_object_definitions|
        [
          {
            name: 'accountId',
            label: 'Account ID',
            hint: 'The Atlassian account ID of the user, e.g. 5b10a2844c20165700ede21g.',
            optional: false
          }
        ]
      end,
    
      execute: lambda do |connection, input|
        get("https://api.atlassian.com/admin/v1/orgs/#{connection['org_id']}/directory/users/#{input['accountId']}/last-active-dates")
          .headers(
            'Authorization' => "Bearer #{connection['admin_api_key']}",
            'Accept'        => 'application/json'
          )
      end,
    
      output_fields: lambda do |object_definitions|
        object_definitions['get_user_last_active_dates_output']
      end
    },

    # --------------------------------------------------------------------------
    # ACTION 2 — Get user (Jira)
    # GET https://{subdomain}.atlassian.net/rest/api/3/user
    # Docs: https://developer.atlassian.com/cloud/jira/platform/rest/v3/
    #         api-group-users/#api-rest-api-3-user-get
    # Auth: Basic base64(email:jira_api_token)
    # --------------------------------------------------------------------------
    get_jira_user: {
      title: 'USERS (Jira) Get user by account ID or username',
      subtitle: 'Returns details of a Jira user by account ID, username',
      description: 'Calls GET /rest/api/3/user. At least one of Account ID, ' \
                   'Username, or Email must be provided. Account ID is preferred ' \
                   'as usernames and emails may be ambiguous.',

      input_fields: lambda do |_object_definitions|
        [
          {
            name: 'accountId',
            label: 'Account ID',
            hint: 'The Atlassian account ID of the user, e.g. 5b10a2844c20165700ede21g. ' \
                  'This is the preferred and most reliable identifier.',
            optional: true
          },
          {
            name: 'username',
            label: 'Username',
            hint: 'Username of the user. Only available if the site uses ' \
                  'username-based authentication.',
            optional: true
          }
        ]
      end,

      execute: lambda do |connection, input|
        # Build Basic auth header: Base64("email:api_token")
        raw_cred    = "#{connection['jira_email']}:#{connection['jira_api_token']}"
        encoded     = raw_cred.encode_base64.gsub("\n", '')
        base_url    = "https://#{connection['jira_subdomain']}.atlassian.net"

        # Build query params — only include non-blank ones
        params = {}
        params['accountId'] = input['accountId'] if input['accountId'].present?
        params['username']  = input['username']  if input['username'].present?

        get("#{base_url}/rest/api/3/user")
          .params(params)
          .headers(
            'Authorization' => "Basic #{encoded}",
            'Accept'        => 'application/json'
          )
      end,

      output_fields: lambda do |object_definitions|
        object_definitions[:get_jira_user_output]
      end,
    },
    
    search_jira_user: {
      title: 'USERS (Jira) - Search user by email',
      subtitle: 'Returns a list of Jira usesr by account ID, username, or email.',
      description: 'Returns a list of Jira usesr by account ID, username, or email.',

      input_fields: lambda do |_object_definitions|
        [
          {
            name: 'email',
            label: 'Email',
            hint: 'The Atlassian email of the user',
            optional: false
          }
        ]
      end,

      execute: lambda do |connection, input|
        # Build Basic auth header: Base64("email:api_token")
        raw_cred    = "#{connection['jira_email']}:#{connection['jira_api_token']}"
        encoded     = raw_cred.encode_base64.gsub("\n", '')
        base_url    = "https://#{connection['jira_subdomain']}.atlassian.net"

        # Build query params — only include non-blank ones
        params = {}
        params['query'] = input['email'] if input['email'].present?

        results = get("#{base_url}/rest/api/3/user/search")
          .params(params)
          .headers(
            'Authorization' => "Basic #{encoded}",
            'Accept'        => 'application/json'
          )
        
        { 'results' => results }
      end,

      output_fields: lambda do |object_definitions|
        [
          {
            name: 'results',
            label: 'Users',
            type: 'array',
            of: 'object',
            properties: object_definitions[:get_jira_user_output]
          }
        ]
      end,
    },
    
    get_jira_user_groups: {
      title: 'USERS (Jira) - Get groups for a user',
      subtitle: 'Returns all Jira groups the given user belongs to.',
      description: 'Calls GET /rest/api/3/user/groups. Requires the user\'s ' \
                   'account ID. The calling user must have Administer Jira ' \
                   'global permission.',
    
      input_fields: lambda do |_object_definitions|
        [
          {
            name: 'accountId',
            label: 'Account ID',
            hint: 'The account ID of the user, e.g. 5b10a2844c20165700ede21g.',
            optional: false
          }
        ]
      end,
    
      execute: lambda do |connection, input|
        raw_cred = "#{connection['jira_email']}:#{connection['jira_api_token']}"
        encoded  = raw_cred.encode_base64.gsub("\n", '')
        base_url = "https://#{connection['jira_subdomain']}.atlassian.net"
    
        results = get("#{base_url}/rest/api/3/user/groups")
                    .params('accountId' => input['accountId'])
                    .headers(
                      'Authorization' => "Basic #{encoded}",
                      'Accept'        => 'application/json'
                    )
    
        { 'groups' => results }
      end,
    
      output_fields: lambda do |object_definitions|
        object_definitions['get_jira_user_groups_output']
      end
    },
    
  },
  
  object_definitions: {
    get_jira_user_output: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: 'self',         label: 'Self URL' },
          { name: 'accountId',    label: 'Account ID' },
          { name: 'accountType',  label: 'Account type' },
          { name: 'emailAddress', label: 'Email address' },
          {
            name: 'avatarUrls',
            label: 'Avatar URLs',
            type: 'object',
            properties: [
              { name: '48x48', label: '48x48' },
              { name: '24x24', label: '24x24' },
              { name: '16x16', label: '16x16' },
              { name: '32x32', label: '32x32' }
            ]
          },
          { name: 'displayName', label: 'Display name' },
          { name: 'active',      label: 'Active?', type: 'boolean' },
          { name: 'timeZone',    label: 'Time zone' },
          { name: 'locale',      label: 'Locale' },
          {
            name: 'groups',
            label: 'Groups (expanded)',
            type: 'object',
            properties: [
              { name: 'size', label: 'Count', type: 'integer' },
              {
                name: 'items',
                label: 'Items',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'name', label: 'Group name' },
                  { name: 'self', label: 'Self URL' }
                ]
              }
            ]
          },
          {
            name: 'applicationRoles',
            label: 'Application roles (expanded)',
            type: 'object',
            properties: [
              { name: 'size', label: 'Count', type: 'integer' },
              {
                name: 'items',
                label: 'Items',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'key',  label: 'Key' },
                  { name: 'name', label: 'Name' }
                ]
              }
            ]
          }
        ]
      end
    },
          
    invite_user_output: {
      fields: lambda do |_connection, _config_fields|
        [
          {
            name: 'data',
            label: 'Invitation results',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'id',    label: 'Invite ID' },
              { name: 'email', label: 'Email address' },
              {
                name: 'results',
                label: 'Assignment results',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'roleAssignmentResult',  label: 'Role assignment result',  type: 'object', properties: [] },
                  { name: 'groupAssignmentResult', label: 'Group assignment result', type: 'object', properties: [] }
                ]
              }
            ]
          }
        ]
      end
    },
    
    get_all_organization_users_output: {
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
              { name: 'platformRoles', type: 'array', of: 'string' },
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
    },
    
    get_jira_user_groups_output: {
      fields: lambda do |_connection, _config_fields|
        [
          {
            name: 'groups',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'groupId', type: 'string' },
              { name: 'name', type: 'string' },
              { name: 'self', type: 'string' }
            ]
          }
        ]
      end
    },
    
    get_user_last_active_dates_output: {
      fields: lambda do |_connection, _config_fields|
        [
          {
            name: 'data',
            type: 'object',
            properties: [
              {
                name: 'product_access',
                type: 'array',
                of: 'object',
                properties: [
                  { name: 'id', type: 'string' },
                  { name: 'key', type: 'string' },
                  { name: 'last_active', type: 'string' },
                  { name: 'last_active_timestamp', type: 'string' }
                ]
              },
              { name: 'added_to_org', type: 'string' },
              { name: 'added_to_org_timestamp', type: 'string' }
            ]
          },
          {
            name: 'links',
            type: 'object',
            properties: [
              { name: 'next', type: 'string' }
            ]
          }
        ]
      end
    }
  },
  
  pick_lists: {
    directories_list: lambda do |connection|
    # organization_id is passed as a parameter from the input field
      response = get("https://api.atlassian.com/admin/v2/orgs/#{connection['org_id']}/directories")
      .headers('Authorization' => "Bearer #{connection['admin_api_key']}")
    
      response["data"].map do |directory|
        [directory["name"], directory["directoryId"]]
      end
    end,
  }
}