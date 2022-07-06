___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Criteo Events Tag",
  "categories": [
    "ANALYTICS", 
    "ADVERTISING", 
    "REMARKETING"
  ],
  "brand": {
    "id": "github.com_ayruz-data-marketing",
    "displayName": "Ayruz-data-marketing"
  },
  "description": "Tag that sends the event data from your tagging server to the Criteo Events API. IMPORTANT: For this tag to function optimally, also add the “Criteo User Identification” template to your web container",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "appId",
    "displayName": "App ID",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "partnerId",
    "displayName": "Partner ID",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "POSITIVE_NUMBER"
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "enableSync",
    "checkboxText": "Enable User Synchronization",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "country",
    "displayName": "Country Name",
    "simpleValueType": true,
    "help": "ex. FR",
    "valueValidators": [
      {
        "type": "REGEX",
        "args": [
          "^[A-Z]{2}$|^{0}$"
        ]
      }
    ],
    "canBeEmptyString": true
  },
  {
    "type": "TEXT",
    "name": "lang",
    "displayName": "Language",
    "simpleValueType": true,
    "canBeEmptyString": true,
    "help": "ex. fr",
    "valueValidators": [
      {
        "type": "REGEX",
        "args": [
          "^[a-z]{2}$|^{0}$"
        ]
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "callerId",
    "displayName": "Caller ID",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NUMBER"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const sendHttpRequest = require('sendHttpRequest');
const getAllEventData = require('getAllEventData');
const getEventData = require('getEventData');
const JSON = require('JSON');
const getCookieValues = require('getCookieValues');
const log = require('logToConsole');

var criteoMappedUserId = getCookieValues("crto_mapped_user_id")[0];
var isUserOptOut = getCookieValues("crto_is_user_optout")[0];

const mappingId = data.appId + '.' + getEventData('event_name');
const urlToCall = 'https://sslwidget.criteo.com/gtm/event?mappingId=' + mappingId;

const postHeaders = {'Content-Type': 'application/json'};

const postBodyData = getPostBody();

const postBody = JSON.stringify(postBodyData);

callWidget(urlToCall, 0);

function callWidget(widgetUrl, redirectLvl) {
    if (redirectLvl > 5) {
      log("Invalid Redirect Loop");
      data.gtmOnFailure();
      return;
    }
    sendHttpRequest(widgetUrl, (statusCode, headers, body) => {
    if (statusCode >= 200 && statusCode < 300) {
      data.gtmOnSuccess();
    } else if (statusCode >= 300 && statusCode < 400){
      callWidget(headers.location, redirectLvl + 1);
    } else {
      data.gtmOnFailure();
    }
  }, {headers: postHeaders, method: 'POST', timeout: 3000}, postBody);
}

function getPostBody() {
    const postBodyData = getAllEventData();
    postBodyData.partner_id = data.partnerId;
    postBodyData.mapping_key = data.callerId;
    postBodyData.mapped_user_id = criteoMappedUserId;
    postBodyData.enable_dising = data.enableSync;
    postBodyData.an = data.appId;
    postBodyData.cn = data.country;
    postBodyData.ln = data.lang;

    if (isUserOptOut === "true") {
        postBodyData.email = null;
        postBodyData.mapping_key = null;
        postBodyData.mapped_user_id = null;
        postBodyData.user_id = null;
        postBodyData.client_id = null;
        postBodyData.ip_override = null;
    }

    return postBodyData;
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "crto_mapped_user_id"
              },
              {
                "type": 1,
                "string": "crto_is_user_optout"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://*.criteo.com/*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 6/22/2022, 6:23:32 PM


