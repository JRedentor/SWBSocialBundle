<%@page import="org.semanticwb.model.SWBContext"%>
<%@page import="org.semanticwb.model.Resource"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="org.semanticwb.SWBPlatform"%>
<%@page import="org.semanticwb.portal.api.SWBParamRequest"%>
<%@page import="org.semanticwb.portal.api.SWBResourceURL"%>
<%@page import="static org.semanticwb.social.admin.resources.Timeline.*"%>

<jsp:useBean id="paramRequest" scope="request" type="org.semanticwb.portal.api.SWBParamRequest"/>

<%
        String lang="";//=paramRequest.getUser().getLanguage();
        String model = SWBContext.WEBSITE_ADMIN;
        String webPageId = paramRequest.getWebPage().getId();


        if(paramRequest.getUser() != null){
            lang = paramRequest.getUser().getLanguage();
        }else{
            lang = "es";
        }
        String resourcePath = "/" + lang + "/" + model + "/" + webPageId + "?";
        //System.out.println("LENGUAJE:" + lang + "----" + SWBContext.WEBSITE_ADMIN);
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("Pragma", "no-cache");        
        String objUri=request.getParameter("suri");
        String param = "suri=" + URLEncoder.encode(request.getParameter("suri")) + "&contentTabId=";
        //System.out.println("parametro en tabs.jsp:" + param);
        String loading="<BR/><center><img src='"+SWBPlatform.getContextPath()+"/swbadmin/css/images/loading.gif'/><center>";
        
        //All tabs are inside the same resource
        //Setting refreshOnShow=false does not reload tab when double-clicked.
        //Div dummy para detectar evento de carga y modificar titulo
        out.println("<div dojoType=\"dijit.layout.ContentPane\" postCreate=\"setTabTitle('"+objUri+"','"+ "Titulo " +"','"+loading+"');\" />");

        out.println("<div dojoType=\"dijit.layout.TabContainer\" region=\"center\" style_=\"border:0px; width:100%; height:100%\" id=\""+objUri+"/tabs/twitter\" _tabPosition=\"bottom\" nested_=\"true\" _selectedChild=\"btab1\" onButtonClick_=\"alert('click');\" onLoad_=\"alert('Hola');\" onDblClick=\"reloadSocialTab('"+objUri+"/tabs/twitter');\">");        
        
        out.println("<div id=\""+ objUri + HOME_TAB +"\" dojoType=\"dijit.layout.ContentPane\" title=\""+"Home"+"\" refreshOnShow=\""+"false"+"\" href=\"" + resourcePath + param + HOME_TAB +"\" _loadingMessage=\""+loading+"\" style_=\"border:0px; width:100%; height:100%\">");
        out.println("</div>");
        
        out.println("<div id=\""+ objUri + MENTIONS_TAB +"\" dojoType=\"dijit.layout.ContentPane\" title=\""+"Mentions"+"\" refreshOnShow=\""+"false"+"\" href=\"" + resourcePath + param + MENTIONS_TAB +"\" _loadingMessage=\""+loading+"\" style_=\"border:0px; width:100%; height:100%\">");
        out.println("</div>");
        
        out.println("<div id=\""+ objUri + FAVORITES_TAB + "\" dojoType=\"dijit.layout.ContentPane\" title=\""+"Favorites"+"\" refreshOnShow=\""+"false"+"\" href=\"" + resourcePath + param + FAVORITES_TAB + "\" _loadingMessage=\""+loading+"\" style_=\"border:0px; width:100%; height:100%\">");
        out.println("</div>");
        
        out.println("<div id=\""+ objUri + DIRECT_MESSAGES_TAB +"\" dojoType=\"dijit.layout.ContentPane\" title=\""+"Direct Messages"+"\" refreshOnShow=\""+"false"+"\" href=\"" + resourcePath + param + DIRECT_MESSAGES_TAB +"\" _loadingMessage=\""+loading+"\" style_=\"border:0px; width:100%; height:100%\">");
        out.println("</div>");
        
        out.println("<div id=\""+ objUri + CONNECTIONS_TAB +"\" dojoType=\"dijit.layout.ContentPane\" title=\""+"Connections"+"\" refreshOnShow=\""+"false"+"\" href=\"" + resourcePath + param + CONNECTIONS_TAB +"\" _loadingMessage=\""+loading+"\" style_=\"border:0px; width:100%; height:100%\">");
        out.println("</div>");

        //out.println("<div id=\""+ objUri + USER_TWEETS_TAB +"\" dojoType=\"dijit.layout.ContentPane\" title=\""+"My Tweets"+"\" refreshOnShow=\""+"false"+"\" href=\"" + resourcePath + param + USER_TWEETS_TAB +"\" _loadingMessage=\""+loading+"\" style_=\"border:0px; width:100%; height:100%\">");
        //out.println("</div>");
        
        //out.println("<div id=\""+ objUri + DISCOVER_TAB +"\" dojoType=\"dijit.layout.ContentPane\" title=\""+"Discover"+"\" refreshOnShow=\""+"true"+"\" href=\"" + resourcePath + param + DISCOVER_TAB +"\" _loadingMessage=\""+loading+"\" style_=\"border:0px; width:100%; height:100%\">");
        //out.println("</div>");        
                
        //out.println("<div id=\""+ objUri +"/profile"+"\" dojoType=\"dijit.layout.ContentPane\" title=\""+"Profile"+"\" refreshOnShow=\""+"true"+"\" href=\""+"/es/SWBAdmin/T_Timeline"+"?" + param + "&contentTabId=showUserProfile&targetUser=dendral"+"\" _loadingMessage=\""+loading+"\" style_=\"border:0px; width:100%; height:100%\">");
        //out.println("</div>");
        
        //out.println("<div id=\"pacone\" dojoType=\"dijit.layout.ContentPane\" title=\"Other Closable\" closable=\"true\" onClose=\"return confirm('really?');\" onLoad=\"onLoadTab(this);\">");
        //    out.println("... I have an in-line onClose");
        //out.println("</div>");
        
        out.println("</div><!-- end Bottom TabContainer -->");
        %>
