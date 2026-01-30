{
  title: 'Slack - team.billing.info - https://docs.slack.dev/reference/methods/team.billing.info',
  
  connection: {
    fields: [
      {
        name: 'client_id',
        label: 'Client ID',
        hint: 'Found in Basic Information > App Credentials',
        optional: false
      },
      {
        name: 'client_secret',
        label: 'Client Secret',
        control_type: 'password',
        hint: 'Found in Basic Information > App Credentials',
        optional: false
      }
    ],
    
    authorization: {
      type: 'oauth2',
      
      authorization_url: lambda do |connection|
        "https://slack.com/oauth/v2/authorize?scope=team.billing:read&client_id=#{connection['client_id']}"
      end,
      
      acquire: lambda do |connection, auth_code, redirect_uri|
        response = post('https://slack.com/api/oauth.v2.access').
                     payload(
                       client_id: connection['client_id'],
                       client_secret: connection['client_secret'],
                       code: auth_code,
                       redirect_uri: redirect_uri
                     ).
                     request_format_www_form_urlencoded
        
        # Slack OAuth v2 returns tokens in a nested structure
        # We'll use the bot token for API calls
        {
          access_token: response['access_token'] || response.dig('authed_user', 'access_token'),
          team_id: response['team', 'id'],
          team_name: response['team', 'name']
        }
      end,
      
      apply: lambda do |connection, access_token|
        headers('Authorization': "Bearer #{access_token}")
      end,
      
      refresh_on: [401, 403],
      
      detect_on: [
        'invalid_auth',
        'account_inactive',
        'token_revoked',
        'no_permission'
      ]
    },
    
    base_uri: lambda do |connection|
      'https://slack.com/api'
    end
  },
  
  test: lambda do |connection|
    # Test the connection by calling auth.test
    get('/auth.test')
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
        
        response = get('/team.billing.info', params)
        
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
      title: 'Get billable users information',
      subtitle: 'Get billing status for team users',
      description: 'Lists billable information for each user - whether they are subject to billing per Fair Billing policy',
      
      input_fields: lambda do |object_definitions|
        [
          {
            name: 'user',
            label: 'User ID',
            hint: 'Optional. Get info for a specific user. Defaults to all users.',
            optional: true
          },
          {
            name: 'team_id',
            label: 'Team ID',
            hint: 'Optional. Only relevant for org-level tokens',
            optional: true
          }
        ]
      end,
      
      execute: lambda do |connection, input, input_schema, output_schema|
        params = {}
        params['user'] = input['user'] if input['user'].present?
        params['team_id'] = input['team_id'] if input['team_id'].present?
        
        response = get('/team.billableInfo', params)
        
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
            label: 'Billable Information',
            properties: [
              {
                name: 'billing_active',
                type: 'boolean',
                label: 'Billing Active'
              }
            ]
          },
          {
            name: 'error',
            label: 'Error message'
          }
        ]
      end,
      
      sample_output: lambda do |connection, input|
        {
          'ok' => true,
          'billable_info' => {
            'U0632EWRW' => {
              'billing_active' => false
            },
            'U02UCPE1R' => {
              'billing_active' => true
            }
          }
        }
      end
    }
  },
  
  triggers: {},
  
  object_definitions: {},
  
  picklists: {},
  
  methods: {}
}