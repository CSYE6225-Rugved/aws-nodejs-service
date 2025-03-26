const { createLogger, transports, format } = require('winston');

const logFormat = format.printf(({ level, message, timestamp, httpRequest}) => {
    return JSON.stringify({
      timestamp: timestamp,
      severity: level.toUpperCase(),
      message,
      httpRequest
    })
  });

const logger = createLogger({
  level: "debug",
  format: format.combine(format.timestamp(), logFormat),
  transports: [
    new transports.File({ filename: '/opt/webapp/logs/csye6225.log' }),
    new transports.Console(),
  ],
});


module.exports = logger;