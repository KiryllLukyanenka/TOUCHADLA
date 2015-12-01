/**
 *
 *
 */
public abstract class Logger {
	public static String LOG_OPTIONS_CACHE_LOG_MESSAGES='cacheLog';
	public static integer DEBUG = 1;
	public static integer INFO = 2;
	public static integer WARNING = 3;
	public static integer ERROR = 4;
	
	private static map<Integer,String> logLevelNumberMap = new map<Integer,String>{
				DEBUG => 'DEBUG', 
				INFO => 'INFO', 
				WARNING => 'WARNING',  
				ERROR => 'ERROR'
	};
	
	private static map<String,Log_Level__c> logLevelDbMap = new map<String,Log_Level__c>();
	
	
	public static Logger getLogger(String className){
		Logger dbLogger = new DBLogger();
		dbLogger.setClassName(className);
		return dbLogger;
	}
	
	private String className;
	
	public String getClassName(){
		return className;
	}
	
	public void setClassName(String className){
		this.className = className;
	}
	
	private integer level;
	
	public Integer getLevel(){
		return level;
	}
	
	public void setLevel(integer level){
		this.level = level;
	}
	
	protected LogMessage logMsg;
	
	public map<String,Object> logOptions = new map<String,Object>();
	
	public virtual void log(integer level,String message){
		this.logMsg = createLogMessage(level,message,getClassName());
	}
	public virtual void log(integer level,String message,Exception e){
		this.logMsg = createLogMessage(level,message,e,getClassName());
	}
	
	public virtual void info(String message){
		log(Info,message);
	}
	public virtual void debug(String message){
	    log(Debug,message);
	}
	
	public virtual void warn(String message){
	    log(Warning,message);
	}
	public virtual void error(String message){
	    log(Error,message);
	}
	public virtual void warn(String message, Exception e){
	    log(WARNING,message,e);
	}
	public virtual void error(String message, Exception e){
	    log(Error,message,e);
	}
	public virtual void commitCachedLogs(){
		
	}
	
	public class LogMessage{
		public LogMessage(){
			userId=Userinfo.getUserId();
			timeStamp = System.now();
		}
		private Integer level;
		private String getLevelStr(){
			return logLevelNumberMap.get(level);
		}
		private String message;
		private String exceptionStack;
		private String className;
		private String userId;
		private String orgId;
		private DateTime timestamp;
	}
	
	public static LogMessage createLogMessage(Integer level,String message){
		LogMessage logMsg = new LogMessage();
		logMsg.message = message;
		logMsg.level = level;
		return logMsg;
	}
	
	
	public static LogMessage createLogMessage(Integer level, String message, Exception ex){
		LogMessage logMsg = new LogMessage();
		logMsg.message = message;
		logMsg.level = level;
		logMsg.exceptionStack = ex.getStackTraceString();
		return logMsg;
	}
	
	public static LogMessage createLogMessage(Integer level, String message, String className){
		LogMessage logMsg = new LogMessage();
		logMsg.message = message;
		logMsg.level = level;
		logMsg.className = className;
		return logMsg;
	}
	
	public static LogMessage createLogMessage(Integer level, String message,Exception ex, String className){
		LogMessage logMsg = new LogMessage();
		logMsg.message = message;
		logMsg.level = level;
		logMsg.exceptionStack = ex.getStackTraceString();
		logMsg.className = className;
		return logMsg;
	}

	/**
	 * Default DB Logger Implementation. This will be used to store Logs in the DB. 
	 */
	public class DbLogger extends Logger{
		
		private list<LogMessage> logMessagesInMemory = new list<LogMessage>();
		
	
		private Boolean isLogMessagesCachingEnabled(){
			return Boolean.valueOf(logOptions.get(LOG_OPTIONS_CACHE_LOG_MESSAGES)+'');
		}
		public virtual override void log(integer level,String message){
			try{
				super.log(level,message);
				logMessagesInMemory.add(logMsg);
				if(!isLogMessagesCachingEnabled()){
					persistLogMessageToDb(logMessagesInMemory);
					logMessagesInMemory.clear();
				}
			}catch(Exception e){
				
			}
		}
		
		public virtual override void log(integer level,String message,Exception e){
			try{
				super.log(level,message,e);
				logMessagesInMemory.add(logMsg);
				if(!isLogMessagesCachingEnabled()){
					persistLogMessageToDb(logMessagesInMemory);
					logMessagesInMemory.clear();
				}
			}catch(Exception ex){
				
			}	
		}
		
		public virtual override void commitCachedLogs(){
			try{
				persistLogMessageToDb(logMessagesInMemory);
				logMessagesInMemory.clear();
			}catch(Exception ex){
				
			}
		}
		
		private Log_Level__c getDBLogLevel(String levelStr, Integer level){
			Log_Level__c logLevel = logLevelDbMap.get(levelStr);
			if(logLevel == null){
				logLevel = new Log_Level__c();
				logLevel.Log_Level_Name__c = levelStr;
				logLevel.Name = levelStr;
				logLevel.Level__c = level;
				insert logLevel;
				logLevelDbMap.put(levelStr,logLevel);
			}
			return logLevel;
		}
		
		private Logger__c getDBLogger(){
			Logger__c logger = null;
			try{
				logger = [select LoggerName__c,Class_Name__c,LogLevel__c from Logger__c where Class_Name__c =: className limit 1 ];
			}catch(Exception e){}
			
			if(logger==null){
			 	logger = new Logger__c();
			 	logger.name = getClassName();
			 	insert logger;
			}
			return logger;
		}
		
		private void persistLogMessageToDb(list<LogMessage> logMsgs){
			//Query for Logger with className==Name
			Logger__c logger = getDBLogger();
			list<Log_Message__c> dbLogMsgs = new list<Log_Message__c>();
			for(LogMessage logMsg:logMsgs){
				Log_Message__c dbLogMsg = new Log_Message__c();
				dbLogMsg.Logger__c = logger.Id;
				dbLogMsg.LogLevel__c = getDBLogLevel(logMsg.getLevelStr(),logMsg.level).Id;
		 		dbLogMsg.Class_Name__c = logMsg.className;
		 		dbLogMsg.Mesage__c = logMsg.message;
		 		dbLogMsg.Stack_Trace__c = logMsg.exceptionStack;
		 		dbLogMsg.User__c = logMsg.userId;
		 		dbLogMsg.Time_Stamp__c = logMsg.timeStamp;
		 		dbLogMsgs.add(dbLogMsg);
			}
		 	insert dbLogMsgs;
			// If query returns with a Logger__c, get the id of the object
			// else create new Logger__c with name as class name and insert
			//Create new Log_Message__c and populate all fields from logMsg variable in to Log_Message__c
			//log_message__c.logger_id__c = logger.id
		}
	}
	
	/**
	 * Default No Logger Implementation. This will be used to turn-off logging feature or when log level is set to No Logger 
	 */
	public class NoLogger extends Logger{
		
		
		public virtual override void log(integer level,String message){
			
		}
		
		public virtual override void log(integer level,String message,Exception e){
			
		}
	}
}