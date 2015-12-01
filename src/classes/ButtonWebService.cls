global class ButtonWebService {
    
    // Added by eric@touchpointcrm.com on 2014-6-9
    webservice static String extendExpiration(String portalUserName, String opportunityId){
        Opportunity oppt = [select Name, OwnerId, Owner.Name, Account.Name, CreatedDate, CloseDate from Opportunity where Id = :opportunityId];
        
        String text = ', ' + portalUserName + ' has requested that the opportunity ' + oppt.Name +  ' for ' + oppt.Account.Name + ' be extended.\n\n'
                    + 'Opportunity Create Date: ' + oppt.CreatedDate.format() + '\nCurrent Expiration: ' + oppt.CloseDate.format();
        
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput(); 
        textSegment.text = text;
        
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = oppt.OwnerId;
        
        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput(); 
        body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        body.messageSegments.add(mentionSegment);
        body.messageSegments.add(textSegment);
        
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.body = body;
        
        try{
            ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, opportunityId, input, null);
            return 'true';
        }
        catch(Exception ex){
            return 'false';
        }
    }
    
    // Added by eric@touchpointcrm.com on 2014-6-10
    webservice static String requestQuote(String portalUserId, String opportunityId){
        Opportunity oppt = [select Name, OwnerId, Owner.Name, Account.Name from Opportunity where Id = :opportunityId];
        String text = ', ' + oppt.Name + ' is ready for a quote/proposal. Please create and let me know when it’s ready. ';
        
        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput(); 
        body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        ConnectApi.TextSegmentInput textSegment;
        ConnectApi.MentionSegmentInput mentionSegment;

        mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = oppt.OwnerId;
        body.messageSegments.add(mentionSegment);
        
        textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = text;
        body.messageSegments.add(textSegment);
        
        mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = portalUserId;
        body.messageSegments.add(mentionSegment);
        
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.body = body;
        
        try{
            ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, oppt.Id, input, null);
            return 'true';
        }
        catch(Exception ex){
            return 'false';
        }
    }
    
    // Added by eric@touchpointcrm.com on 2014-6-25
    webservice static String closedOrWon(String portalUserName, String opportunityId){
        Opportunity oppt = [select Name, OwnerId, Owner.Name, Account.Name, CreatedDate, CloseDate from Opportunity where Id = :opportunityId];
        
        String text = ', ' + portalUserName + ' has indicated that the opportunity is ready to be made "Closed/Won".';
        
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput(); 
        textSegment.text = text;
        
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = oppt.OwnerId;
        
        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput(); 
        body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        body.messageSegments.add(mentionSegment);
        body.messageSegments.add(textSegment);
        
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.body = body;
        
        try{
            ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, opportunityId, input, null);
            return 'true';
        }
        catch(Exception ex){
            return 'false';
        }
    }
}