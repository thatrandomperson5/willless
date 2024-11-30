import std/[logging, os]

let defaultLoggingFile* = getAppFilename().splitFile().name & "_willless_debug.log"
var debugLog*: Logger 
when defined(willlessDebugToConsole):
  debugLog = newConsolerLogger()
else:
  debugLog = newFileLogger(defaultLoggingFile)

template debug*(args: varargs[string, `$`]) = debugLog.log(lvlDebug, args)

template info*(args: varargs[string, `$`]) = debugLog.log(lvlInfo, args)

template error*(args: varargs[string, `$`]) = debugLog.log(lvlError, args)

export log