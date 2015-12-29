const http = require('http');

let ips = [];

http.createServer(function(req, res) {
  res.writeHead(200, {
    'Content-Type': 'text/json',
    'Connection': 'close'
  });

  if ( req.url.indexOf('register') >= 0 ) {
    let match = req.url.match(/ip=([0-9.]+)/);

    if ( match ) {
      ips = ips.filter((ip) => match[1] != ip);
      ips.unshift(match[1]);
    }
  }

  res.end(JSON.stringify(ips));
}).listen(8001);
