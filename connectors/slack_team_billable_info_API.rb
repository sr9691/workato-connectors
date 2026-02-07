{
  title: 'Slack - team.billableinfo - https://docs.slack.dev/reference/methods/team.billableInfo',

  connection: {
    fields: [
      {
        name: 'client_id',
        label: 'Client ID',
        optional: false,
        hint: 'Find this in your Slack app settings under Basic Information > App Credentials'
      },
      {
        name: 'client_secret',
        label: 'Client Secret',
        control_type: 'password',
        optional: false,
        hint: 'Find this in your Slack app settings under Basic Information > App Credentials'
      }
    ],

    authorization: {
      type: 'oauth2',

      authorization_url: lambda do |connection|
        params = {
          client_id: connection['client_id'],
          user_scope: 'team:read team.billing:read admin'
        }.to_param
        
        "https://slack.com/oauth/v2/authorize?#{params}"
      end,

      acquire: lambda do |connection, auth_code, redirect_uri|
        response = post('https://slack.com/api/oauth.v2.access').
                     payload(
                       code: auth_code,
                       client_id: connection['client_id'],
                       client_secret: connection['client_secret'],
                       redirect_uri: redirect_uri
                     ).
                     request_format_www_form_urlencoded

        # Slack returns the access token in the 'authed_user' object for user tokens
        access_token = response.dig('authed_user', 'access_token') || response['access_token']
        
        {access_token: access_token}
        #[{
        #  access_token: access_token,
        #  team_id: response['team', 'id']
        #}, nil, nil]
      end,

      apply: lambda do |connection, access_token|
        headers('Authorization': "Bearer #{access_token}")
      end,

      detect_on: [401, 403],

      refresh_on: [401, 403]
    },

    base_uri: lambda do |connection|
      'https://slack.com/api'
    end
  },

  test: lambda do |connection|
    get('/api/team.billableInfo')
  end,

  actions: {
    
    get_billing_info: {
      title: 'Get team billing information',
      subtitle: 'Retrieve billing plan details for the workspace',
      description: 'Get the billing plan type (free, std, plus, enterprise, compliance) for the Slack workspace',
      
      input_fields: lambda do |object_definitions|
        [
          {
            name: 'team_id',
            label: 'Team ID',
            hint: 'Optional. Only needed for org-level tokens',
            optional: true
          }
        ]
      end,
      
      execute: lambda do |connection, input, input_schema, output_schema|
        params = {}
        params['team'] = input['team_id'] if input['team_id'].present?
        
        response = get('/api/team.billing.info', params)
        
        # Return the response
        response
      end,
      
      output_fields: lambda do |object_definitions|
        [
          {
            name: 'ok',
            type: 'boolean',
            label: 'Success'
          },
          {
            name: 'plan',
            label: 'Billing Plan',
            hint: 'Plan type: free, std, plus, enterprise, or compliance'
          },
          {
            name: 'error',
            label: 'Error message',
            hint: 'Present if ok is false'
          }
        ]
      end,
      
      sample_output: lambda do |connection, input|
        {
          'ok' => true,
          'plan' => 'std'
        }
      end
    },
    
    get_billable_info: {
      title: 'List billable users',
      subtitle: 'Get billable users information for the team',
      description: 'Retrieves billable information for users on the Slack team',
      help: 'This action returns billing status for team members based on Slack\'s Fair Billing policy',

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'user',
            label: 'User ID',
            optional: true,
            hint: 'Slack user ID (e.g., U1234567890). Leave empty to get all users.'
          },
          {
            name: 'cursor',
            label: 'Cursor',
            optional: true,
            hint: 'Pagination cursor from previous response'
          },
          {
            name: 'limit',
            label: 'Limit',
            type: 'integer',
            optional: true,
            hint: 'Maximum number of items to return (default: 100)'
          }
        ]
      end,

      execute: lambda do |connection, input|
        params = {}
        params['user'] = input['user'] if input['user'].present?
        params['cursor'] = input['cursor'] if input['cursor'].present?
        params['limit'] = input['limit'] if input['limit'].present?

        response = get('/api/team.billableInfo').
                     params(params).
                     after_error_response(/.*/) do |code, body, headers, message|
                       error("#{code}: #{body}")
                     end

        response
      end,

      output_fields: lambda do |object_definitions|
        [
          {
            name: 'ok',
            type: 'boolean',
            label: 'Success'
          },
          {
            name: 'billable_info',
            type: 'object',
            label: 'Billable information',
            properties: [
              {
                name: 'billing_active',
                type: 'boolean',
                label: 'Billing active'
              }
            ]
          },
          {
            name: 'response_metadata',
            type: 'object',
            label: 'Response metadata',
            properties: [
              {
                name: 'next_cursor',
                label: 'Next cursor'
              }
            ]
          }
        ]
      end,

      sample_output: lambda do |connection, input|
        {
          ok: true,
          billable_info: {
            "U0632EWRW": {
              billing_active: false
            },
            "U02UCPE1R": {
              billing_active: true
            },
            "U02UEBSD2": {
              billing_active: true
            }
          },
          response_metadata: {
            next_cursor: ""
          }
        }
      end
    },

    get_team_info: {
      title: 'Get team information',
      subtitle: 'Get basic team info',
      description: 'Retrieves basic information about the Slack team/workspace',

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'team',
            label: 'Team ID',
            optional: true,
            hint: 'Team ID to get info about (optional)'
          }
        ]
      end,

      execute: lambda do |connection, input|
        params = {}
        params['team'] = input['team'] if input['team'].present?

        response = get('/api/team.info').
                     params(params).
                     after_error_response(/.*/) do |code, body, headers, message|
                       error("#{code}: #{body}")
                     end

        response
      end,

      output_fields: lambda do |object_definitions|
        [
          {
            name: 'ok',
            type: 'boolean'
          },
          {
            name: 'team',
            type: 'object',
            properties: [
              { name: 'id', label: 'Team ID' },
              { name: 'name', label: 'Team name' },
              { name: 'domain', label: 'Domain' },
              { name: 'email_domain', label: 'Email domain' },
              {
                name: 'icon',
                type: 'object',
                properties: [
                  { name: 'image_default', type: 'boolean' },
                  { name: 'image_34' },
                  { name: 'image_44' },
                  { name: 'image_68' },
                  { name: 'image_88' },
                  { name: 'image_102' },
                  { name: 'image_132' }
                ]
              },
              { name: 'enterprise_id', label: 'Enterprise ID', optional: true },
              { name: 'enterprise_name', label: 'Enterprise name', optional: true }
            ]
          }
        ]
      end,

      sample_output: lambda do |connection, input|
        {
          ok: true,
          team: {
            id: "T12345",
            name: "My Team",
            domain: "example",
            email_domain: "example.com",
            icon: {
              image_34: "https://...",
              image_44: "https://...",
              image_68: "https://...",
              image_88: "https://...",
              image_102: "https://...",
              image_132: "https://...",
              image_default: true
            }
          }
        }
      end
    },

    list_all_billable_users: {
      title: 'List all billable users (auto pagination)',
      subtitle: 'Get all billable users with pagination',
      description: 'Retrieves all billable users, handling pagination automatically',
      help: 'This action will fetch all billable users across multiple pages',

      execute: lambda do |connection, input|
        billable_users = []
        cursor = nil
        
        loop do
          params = { limit: 100 }
          params['cursor'] = cursor if cursor.present?
          
          response = get('/api/team.billableInfo').
                       params(params).
                       after_error_response(/.*/) do |code, body, headers, message|
                         error("#{code}: #{body}")
                       end
          
          if response['billable_info'].present?
            response['billable_info'].each do |user_id, info|
              billable_users << {
                user_id: user_id,
                billing_active: info['billing_active']
              }
            end
          end
          
          cursor = response.dig('response_metadata', 'next_cursor')
          break if cursor.blank?
        end
        
        {
          users: billable_users,
          total_count: billable_users.length,
          active_count: billable_users.count { |u| u[:billing_active] },
          inactive_count: billable_users.count { |u| !u[:billing_active] }
        }
      end,

      output_fields: lambda do |object_definitions|
        [
          {
            name: 'users',
            type: 'array',
            of: 'object',
            properties: [
              { name: 'user_id', label: 'User ID' },
              { name: 'billing_active', type: 'boolean', label: 'Billing active' }
            ]
          },
          { name: 'total_count', type: 'integer', label: 'Total users' },
          { name: 'active_count', type: 'integer', label: 'Active billable users' },
          { name: 'inactive_count', type: 'integer', label: 'Inactive users' }
        ]
      end,

      sample_output: lambda do |connection, input|
        {
          users: [
            { user_id: "U0632EWRW", billing_active: false },
            { user_id: "U02UCPE1R", billing_active: true },
            { user_id: "U02UEBSD2", billing_active: true }
          ],
          total_count: 3,
          active_count: 2,
          inactive_count: 1
        }
      end
    }

  },

  triggers: {
    # Triggers can be added here if needed
  },

  object_definitions: {
    # Object definitions can be added here for reusability
  },

  picklists: {
    # Picklists can be added here if needed
  },

  methods: {
    # Helper methods can be added here
  }
}