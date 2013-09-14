zent
====

Anonymous thought stream.

## Usage

All requests are relative to `http://zentapp.herokuapp.com` and return JSON, except where noted.

### GET `/`

Get all thoughts

### POST `/`

Create a new thought.

Required parameters: `content`
Optional Parameters: `original_messsage_id`

Sample request body:

```
{
  "message": {
    "content": "Hello, World",
    "original_message_id": "1"
  }
}
```

### GET `/zen`

Returns a random thought.

### GET `/zen.txt`

Same as GET `/zen`, except returns only the thought's content, in `text/plain` format.

### GET `/path-of-zen`

Redirects to a random thought.

### GET `/:id`

Returns thought with id `:id`.
