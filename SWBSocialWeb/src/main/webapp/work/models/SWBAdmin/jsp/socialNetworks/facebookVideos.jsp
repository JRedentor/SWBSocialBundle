<%-- 
    Document   : facebookVideos
    Created on : 10/06/2013, 09:50:18 AM
    Author     : francisco.jimenez
--%>
<%@page import="java.util.regex.Pattern"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="org.semanticwb.model.WebSite"%>
<%@page import="org.semanticwb.model.SWBModel"%>
<%@page import="org.semanticwb.social.PostIn"%>
<%@page import="java.util.Iterator"%>
<%@page import="org.semanticwb.platform.SemanticObject"%>
<%@page import="java.util.TimeZone"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="org.semanticwb.social.Facebook"%>
<%@page import="org.semanticwb.portal.api.SWBParamRequest"%>
<%@page import="java.io.Writer"%>
<%@page import="org.semanticwb.portal.api.SWBResourceURL"%>
<%@page import="java.util.HashMap"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONException"%>
<%@page import="org.json.JSONObject"%>
<jsp:useBean id="paramRequest" scope="request" type="org.semanticwb.portal.api.SWBParamRequest"/>
<jsp:useBean id="facebookBean" scope="request" type="org.semanticwb.social.Facebook"/>
<%@page import="static org.semanticwb.social.admin.resources.FacebookWall.*"%>
<%@page contentType="text/html" pageEncoding="x-iso-8859-11"%>
<!DOCTYPE html>
<%
    String objUri = (String) request.getParameter("suri");
    SWBModel model = WebSite.ClassMgr.getWebSite(facebookBean.getSemanticObject().getModel().getName());
    HashMap<String, String> params = new HashMap<String, String>(2);
    params.put("access_token", facebookBean.getAccessToken());
    String username = request.getParameter("title");
//    String user = postRequest(params, "https://graph.facebook.com/me",
//                            "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.95", "GET");
//    JSONObject userObj = new JSONObject(user);
//    if (!userObj.isNull("name")) {
//        username = userObj.getString("name");
//    } else {
//        username = facebookBean.getTitle();
//    }
%>
<div class="timelineTab" style="padding:10px 5px 10px 5px; overflow-y: scroll; height: 400px;">
    <div class="timelineTab-title">
        <p>
            <strong><%=username%></strong><%=paramRequest.getLocaleString("myVideos")%>
        </p>
    </div>
<%  
    //TODO: it seems that 'likes' is deprecated and it must be replaced with like_info
//    params.put("q", "{\"videos\": \"SELECT actor_id, created_time, like_info, post_id, attachment, message, description, description_tags, type, comment_info FROM stream WHERE filter_key IN " + 
//                "( SELECT filter_key FROM stream_filter WHERE uid = me() AND name = 'Video') ORDER BY created_time DESC LIMIT 50\", \"usernames\": \"SELECT uid, name FROM user WHERE uid IN (SELECT actor_id FROM #videos)\", \"pages\":\"SELECT page_id, name FROM page WHERE page_id IN (SELECT actor_id FROM #videos)\"}");
    params.put("fields", "id,from,picture,created_time,likes.summary(true),source,name,description,tags,comments.limit(5).summary(true)");
    params.put("limit", "30");
    String fbResponse = getRequest(params, Facebook.FACEBOOKGRAPH + "me/videos/uploaded",
                    Facebook.USER_AGENT);
    
    String createdTime = video(fbResponse, out, true, request, paramRequest, model);//Gets the newest post and saves the ID of the last one
    SWBResourceURL renderURL = paramRequest.getRenderUrl().
            setParameter("suri", objUri).
            setParameter("currentTab", VIDEOS_TAB).
            setParameter("createdTime", createdTime);
    if (createdTime != null && !createdTime.isEmpty()) {
%>
    <div id="<%=objUri%>getMoreVideos" dojoType="dijit.layout.ContentPane">
        <div align="center" style="margin-bottom: 10px;">
            <label id="<%=objUri%>moreVideosLabel">
                <a href="#" onclick="appendHtmlAt('<%=renderURL.setMode("getMoreVideos")%>','<%=objUri%>getMoreVideos', 'bottom');try{this.parentNode.parentNode.parentNode.removeChild(this.parentNode.parentNode);}catch(noe){}; return false;">
                    <%=paramRequest.getLocaleString("getMoreVideos")%>
                </a>
            </label>
        </div>
    </div>
<%
    }
%>
</div>
