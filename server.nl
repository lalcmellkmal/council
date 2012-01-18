var fs = require('fs'),
    http = require('http'),
    redis = require('redis');

var ROUTES = {};

function route(url, func) {
	ROUTES[url] = func;
}

var headHtml = fs.readFileSync('head.html', 'UTF-8');

route('/', function (cb) {
	rurrus <- fs.readFile('initial.txt', 'UTF-8');
	var html = headHtml + '<article>' + format(rurrus) + '</article>' +
		'<aside>Oh boy here we go.</aside>';
	return html;
});

route('/base-v1.css', function (cb) {
	css <- fs.readFile('base.css');
	return {mime: 'text/css', body: css};
});

function writeError(resp, err) {
	console.error(err);
	resp.writeHead(500);
	resp.end("Something's gone horribly wrong.");
}

var server = http.createServer(function (req, resp) {
	var f = ROUTES[req.url];
	if (f) {
		f(function (err, body) {
			if (err)
				return writeError(resp, err);
			var headers = {}
			if (body.mime) {
				headers['Content-Type'] = body.mime;
				body = body.body;
			}
			else {
				headers['Content-Type'] = 'text/html; charset=UTF-8';
				headers['Cache-Control'] = 'no-cache';
				headers['Expires'] = 'Thu, 01 Jan 1970 00:00:00 GMT';
			}
			resp.writeHead(200, headers);
			resp.end(body);
		});
		return;
	}

	resp.writeHead(404);
	resp.end('Not found ;_;');
});
server.listen(8000);

function format(text) {
	var rurrus = text.split(/^(\d{3,})\./mi);
	var out = [];
	rurrus.shift();
	while (rurrus.length) {
		var num = parseInt(rurrus.shift().match(/(\d+)/)[1], 10);
		var body = escapeHtml(rurrus.shift());
		body = body.replace(/\n/g, '<br>');
		out.push('<div id="' + num + '">' + num + '.' + body + '</div>\n');
	}
	return out.join('');
}

var entities = {'&' : '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;'};
function escapeHtml(html) {
	return html.replace(/[&<>"]/g, function (c) { return entities[c]; });
}

// vi: set ai filetype=javascript:
