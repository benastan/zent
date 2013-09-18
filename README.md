zent
====

Anonymous thought stream.

REST API Endpoint: http://zentapp.herokuapp.com
JavaScript Client: https://github.com/benastan/zent-client
Web UI: Coming soon!

## Usage

All requests are relative to `http://zentapp.herokuapp.com` and return JSON, except where noted.

### GET `/`

Get all thoughts

### POST `/`

Create a new thought.

Request body should be the content of the message.

### GET `/zen`

Returns a random thought.

### GET `/zen.txt`

Same as GET `/zen`, except returns only the thought's content, in `text/plain` format.

### GET `/path-of-zen`

Redirects to a random thought.

### GET `/:id`

Returns thought with id `:id`.

### PATCH `/:id`

Create a new thought, but set it to reference thought with id `:id`.
