# 4. Rails CSP compliant script tag helpers

Date: 2025-04-29

## Status

Accepted

## Context

The [Content-Security-Policy](https://content-security-policy.com/) header generated by the
[secure_headers](https://github.com/github/secure_headers) gem does not work with Rails UJS AJAX forms.

The Rails UJS AJAX forms might be used if this project does not use a full-on SPA library.

## Decision

Using Rails built-in CSP controls while keeping SecureHeaders in place for other headers results
in a secure system that works seamlessly.

## Consequences

In order to define an inline `<script>` tag, use the `nonce: true` option.

```
<%= javascript_tag nonce: true do %>
  alert("my js runs here");
<% end %>
```

### Nonce pitfall

[source](https://content-security-policy.com/nonce/#:~:text=Avoid%20this%20common%20nonce%20mistake)

If you are outputting variables inside a nonce protected script tag, you could cancel out the XSS protection that CSP is giving you.

For example assume you have a URL such as `/example/?id=123` and you are outputting that id value from the URL in your script block:

```
<%= javascript_tag nonce: true do %>
  var id = <%= params[:id] %>
<% end %>
```

Now an attacker could request the URL: `/example/?id=doSomethingBad()`, and your application would send back:

```
<script nonce="rAnd0m">
	var id = doSomethingBad()
</script>
```

As you can see we just threw away all of the cross site scripting protections of CSP by improperly using the nonce.
