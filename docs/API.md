# Quick Car List API

This details general API information. API endpoints are prefixed with `/api/{version}` where `{version}` is an API version such as v1.

## Authentication

Authentication is handled via a passed in username and password. The successful response returns an authentication token. All requests to authenticated APIs must include this login token or they will receive a 401 Unauthorized error code.

### Login

**POST `/signin`**

#### Request

* email: address of the administrator account
* password: Base64 encoded password

#### Response

	{
	  "token": "oiuozxcy890uqwhpaofpOAJfhpoiAJHoiuoj"
	}

### Logout

**POST `/signout`**

#### Request

* token: retrieved from successful request to [Login](#login)

#### Response

Contains the now invalidated token.

	{
	  "token": "oiuozxcy890uqwhpaofpOAJfhpoiAJHoiuoj"
	}

## Vehicles

### List Vehicles

**GET `/vehicles`**

#### Request

* token: retrieved from successful request to [Login](#login)

#### Response

	{
	  "id": "456787656789",
	  "vin": "34567898765432",
	  "year": "2009",
	  "make": "Honda",
	  "model": "Civic EX",
	  "image": { "id": "17398", "url": "http://abs.url.to/image/source" }
	}

### Get Vehicle

**GET `/vehicle/:id`**

#### Request

* token: retrieved from successful request to [Login](#login)
* id: path parameter containing vehicle id

#### Response

	{
	  "id": "456787656789",
	  "vin": "34567898765432",
	  "year": "2009",
	  "make": "Honda",
	  "model": "Civic EX",
	  "images": [
	    { "id": "17398", "url": "http://abs.url.to/image/source" }
	  ],
	  "info": {
	    ...vin fields...
	  }
	}