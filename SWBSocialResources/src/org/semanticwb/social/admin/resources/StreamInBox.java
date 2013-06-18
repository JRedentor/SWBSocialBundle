/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.semanticwb.social.admin.resources;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Set;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.semanticwb.Logger;
import org.semanticwb.SWBPlatform;
import org.semanticwb.SWBPortal;
import org.semanticwb.SWBUtils;
import org.semanticwb.model.Resource;
import org.semanticwb.model.SWBComparator;
import org.semanticwb.model.WebSite;
import org.semanticwb.platform.SemanticObject;
import org.semanticwb.portal.api.GenericResource;
import org.semanticwb.portal.api.SWBActionResponse;
import org.semanticwb.portal.api.SWBParamRequest;
import org.semanticwb.portal.api.SWBResourceException;
import org.semanticwb.portal.api.SWBResourceURL;
import org.semanticwb.social.MessageIn;
import org.semanticwb.social.PhotoIn;
import org.semanticwb.social.PostIn;
import org.semanticwb.social.SentimentalLearningPhrase;
import org.semanticwb.social.SocialNetwork;
import org.semanticwb.social.SocialPFlow;
import org.semanticwb.social.SocialTopic;
import org.semanticwb.social.Stream;
import org.semanticwb.social.VideoIn;
import org.semanticwb.social.util.SWBSocialComparator;
import org.semanticwb.social.util.SWBSocialUtil;

/**
 *
 * @author jorge.jimenez
 */
public class StreamInBox extends GenericResource {
    
     /** The log. */
    private Logger log = SWBUtils.getLogger(StreamInBox.class);
    /** The webpath. */
    String webpath = SWBPlatform.getContextPath();
    /** The distributor. */
    String distributor = SWBPlatform.getEnv("wb/distributor");
    /** The Mode_ action. */
    //String Mode_Action = "paction";
    String Mode_PFlowMsg="doPflowMsg";
    String Mode_PreView="preview";
    
    /**
     * Creates a new instance of SWBAWebPageContents.
     */
    public StreamInBox() {
    }
    
    public static final String Mode_REVAL = "rv";
    public static final String Mode_RECLASSBYTOPIC="reclassByTopic";
    public static final String Mode_RECLASSBYSENTIMENT="revalue";
    public static final String Mode_RESPONSE="response";
    
    @Override
    public void processRequest(HttpServletRequest request, HttpServletResponse response, SWBParamRequest paramRequest) throws SWBResourceException, IOException {
        final String mode = paramRequest.getMode();
        if(Mode_REVAL.equals(mode)) {
            doRevalue(request, response, paramRequest);
        }else if(Mode_RESPONSE.equals(mode))
        {
            doResponse(request, response, paramRequest);
        }else if (paramRequest.getMode().equals("post")) {
            doCreatePost(request, response, paramRequest);
        }else if(Mode_RECLASSBYTOPIC.equals(mode)) {
            doReClassifyByTopic(request, response, paramRequest);
        } else if(Mode_RECLASSBYSENTIMENT.equals(mode))
        {
            doRevalue(request, response, paramRequest);
        }else{
            super.processRequest(request, response, paramRequest);
        }
    }

    /**
     * User view of the resource, this call to a doEdit() mode.
     *
     * @param request , this holds the parameters
     * @param response , an answer to the user request
     * @param paramRequest , a list of objects like user, webpage, Resource, ...
     * @throws SWBResourceException, a Resource Exception
     * @throws IOException, an In Out Exception
     * @throws SWBResourceException the sWB resource exception
     * @throws IOException Signals that an I/O exception has occurred.
     */
    @Override
    public void doView(HttpServletRequest request, HttpServletResponse response, SWBParamRequest paramRequest) throws SWBResourceException, IOException {
        response.setContentType("text/html; charset=ISO-8859-1");
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("Pragma", "no-cache");
        log.debug("doView(SWBAWebPageContents...)");
        doEdit(request, response, paramRequest);
    }

    /**
     * User edit view of the resource, this show a list of contents related to a webpage, user can add, remove, activate, deactivate contents.
     *
     * @param request , this holds the parameters
     * @param response , an answer to the user request
     * @param paramRequest , a list of objects like user, webpage, Resource, ...
     * @throws SWBResourceException, a Resource Exception
     * @throws IOException, an In Out Exception
     * @throws SWBResourceException the sWB resource exception
     * @throws IOException Signals that an I/O exception has occurred.
     */
    @Override
    public void doEdit(HttpServletRequest request, HttpServletResponse response, SWBParamRequest paramRequest) throws SWBResourceException, IOException 
    {
        String lang=paramRequest.getUser().getLanguage(); 
        response.setContentType("text/html; charset=ISO-8859-1");
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("Pragma", "no-cache");
        log.debug("doEdit()");
        
        String id = request.getParameter("suri");
        if(id==null) return;
        
        System.out.println("Stream-id/doEdit:"+id);

        Stream stream = (Stream)SemanticObject.getSemanticObject(id).getGenericInstance();    
        
        PrintWriter out = response.getWriter();
        
        if (request.getParameter("dialog") != null && request.getParameter("dialog").equals("close")) {
            out.println("<script type=\"javascript\">");
            out.println(" hideDialog(); ");
            if(request.getParameter("statusMsg")!=null) {
                out.println("   showStatus('" + request.getParameter("statusMsg") + "');");
            }
            if(request.getParameter("reloadTap")!=null)
            {
                out.println(" reloadTab('" + id + "'); ");
            }
            out.println("</script>");
        }
        
        String searchWord = request.getParameter("search");
        if (null == searchWord) {
            searchWord = "";
        }
        
        
        SWBResourceURL urls = paramRequest.getRenderUrl();
        urls.setParameter("act", "");
        urls.setParameter("suri", id);
        
        
        out.println("<div class=\"swbform\">");
      
        out.println("<fieldset>");
        out.println("<form id=\"" + id + "/fsearchwp\" name=\"" + id + "/fsearchwp\" method=\"post\" action=\"" + urls + "\" onsubmit=\"submitForm('" + id + "/fsearchwp');return false;\">");
        out.println("<div align=\"right\">");
        out.println("<input type=\"hidden\" name=\"suri\" value=\"" + id + "\">");
        out.println("<label for=\"" + id + "_searchwp\">" + paramRequest.getLocaleString("searchPost") + ": </label><input type=\"text\" name=\"search\" id=\"" + id + "_searchwp\" value=\"" + searchWord + "\">");
        out.println("<button dojoType=\"dijit.form.Button\" type=\"submit\">" + paramRequest.getLocaleString("btnSearch") + "</button>"); //
        out.println("</div>");
        out.println("</form>");
        out.println("</fieldset>");
        
        
        out.println("<fieldset>");
        out.println("<table width=\"98%\" >");
        out.println("<thead>");
        
        out.println("<th>");
        out.println(paramRequest.getLocaleString("action"));
        out.println("</th>");
        
        
        out.println("<th>");
        out.println(paramRequest.getLocaleString("post"));
        out.println("</th>");
        
        SWBResourceURL urlOderby = paramRequest.getRenderUrl();
        urlOderby.setParameter("act", "");
        urlOderby.setParameter("suri", id);
        urlOderby.setParameter("orderBy", "PostType");
        
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("postType")+"</a>"); 
        out.println("</th>");
        
        urlOderby.setParameter("orderBy", "network");
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("network")+"</a>");
        out.println("</th>");
        
        urlOderby.setParameter("orderBy", "topic");
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("topic")+"</a>");
        out.println("</th>");
        
        urlOderby.setParameter("orderBy", "creted");
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("created")+"</a>");
        out.println("</th>");
        
        urlOderby.setParameter("orderBy", "sentiment");
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("sentiment")+"</a>");
        out.println("</th>");
        
        urlOderby.setParameter("orderBy", "intensity");
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("intensity")+"</a>");
        out.println("</th>");
        
        urlOderby.setParameter("orderBy", "emoticon");
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("emoticon")+"</a>");
        out.println("</th>");
        
        urlOderby.setParameter("orderBy", "replies");
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("replies")+"</a>");
        out.println("</th>");
       
        urlOderby.setParameter("orderBy", "user");
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("user")+"</a>");
        out.println("</th>");
        
        urlOderby.setParameter("orderBy", "followers");
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("followers")+"</a>");
        out.println("</th>");
        
        urlOderby.setParameter("orderBy", "friends");
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("friends")+"</a>");
        out.println("</th>");
        
        urlOderby.setParameter("orderBy", "klout");
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("klout")+"</a>");
        out.println("</th>");
        
        urlOderby.setParameter("orderBy", "place");
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("place")+"</a>");
        out.println("</th>");
        
        urlOderby.setParameter("orderBy", "prioritary");
        out.println("<th>");
        out.println("<a href=\"#\"  onclick=\"submitUrl('" + urlOderby + "',this); return false;\">"+paramRequest.getLocaleString("prioritary")+"</a>");
        out.println("</th>");
        
        
        out.println("</thead>");
        out.println("<tbody>");
        
        
        Iterator<PostIn> itposts = PostIn.ClassMgr.listPostInByPostInStream(stream);
        
        //Filtros
        ArrayList<PostIn> aListFilter=new ArrayList();
        if(searchWord!=null)
        {
            while(itposts.hasNext())
            {
                PostIn postIn=itposts.next();
                if(postIn.getTags()!=null && postIn.getTags().toLowerCase().indexOf(searchWord.toLowerCase())>-1)
                {
                    aListFilter.add(postIn);
                }else if(postIn.getMsg_Text()!=null && postIn.getMsg_Text().toLowerCase().indexOf(searchWord.toLowerCase())>-1)
                {
                    aListFilter.add(postIn);
                }
            }
        }
        //Termina Filtros
        
        if(aListFilter.size()>0) 
        {
            itposts=aListFilter.iterator();
        }
         
        //Ordenamientos
        System.out.println("orderBy k Llega:"+request.getParameter("orderBy"));
        Set<PostIn> setso=null;
        if(request.getParameter("orderBy")!=null)
        {
            if(request.getParameter("orderBy").equals("PostType"))
            {
                setso = SWBSocialComparator.sortByPostType(itposts);
            }else if(request.getParameter("orderBy").equals("network"))
            {
                setso = SWBSocialComparator.sortByNetwork(itposts);
            }else if(request.getParameter("orderBy").equals("topic"))
            {
                setso = SWBSocialComparator.sortByTopic(itposts);
            }else if(request.getParameter("orderBy").equals("creted"))
            {
                setso = SWBComparator.sortByCreatedSet(itposts,true);
            }else if(request.getParameter("orderBy").equals("sentiment"))
            {
                setso = SWBSocialComparator.sortBySentiment(itposts, true);
            }else if(request.getParameter("orderBy").equals("intensity"))
            {
                setso = SWBSocialComparator.sortByIntensity(itposts, true);
            }else if(request.getParameter("orderBy").equals("emoticon"))
            {
                setso = SWBSocialComparator.sortByEmoticon(itposts, true);
            }else if(request.getParameter("orderBy").equals("user"))
            {
                setso = SWBSocialComparator.sortByUser(itposts);
            }else if(request.getParameter("orderBy").equals("followers"))
            {
                setso = SWBSocialComparator.sortByFollowers(itposts, true);
            }else if(request.getParameter("orderBy").equals("replies"))
            {
                setso = SWBSocialComparator.sortByReplies(itposts, true);
            }else if(request.getParameter("orderBy").equals("friends"))
            {
                setso = SWBSocialComparator.sortByFriends(itposts, true);
            }else if(request.getParameter("orderBy").equals("klout"))
            {
                setso = SWBSocialComparator.sortByKlout(itposts, true);
            }else if(request.getParameter("orderBy").equals("place"))
            {
                setso = SWBSocialComparator.sortByPlace(itposts);
            }else if(request.getParameter("orderBy").equals("prioritary"))
            {
                setso = SWBSocialComparator.sortByPrioritary(itposts, true);
            }
            
        }else
        {
            setso = SWBComparator.sortByCreatedSet(itposts, false);
        }
        
        
        itposts = null;
        int ps = 20;
        int l = setso.size();

        //System.out.println("num cont: "+l);

        int p = 0;
        String page = request.getParameter("page");
        if (page != null) {
            p = Integer.parseInt(page);
        }



        int x = 0;
        itposts = setso.iterator();
        while (itposts.hasNext()) 
        {
            PostIn postIn = itposts.next();
            
            
            if (x < p * ps) {
                x++;
                continue;
            }
            if (x == (p * ps + ps) || x == l) {
                break;
            }
            x++;
            
            
            out.println("<tr>");
            
            //Show Actions
            out.println("<td>");
        
            //Remove
            SWBResourceURL urlr = paramRequest.getActionUrl();
            urlr.setParameter("suri", id);
            urlr.setParameter("sval", postIn.getURI());
            urlr.setParameter("page", "" + p);
            urlr.setAction("remove");
            
            out.println("<a href=\"#\" title=\"" + paramRequest.getLocaleString("remove") + "\" onclick=\"if(confirm('" + paramRequest.getLocaleString("confirm_remove") + " " + 
                    SWBUtils.TEXT.scape4Script(postIn.getMsg_Text()) + "?'))" + "{ submitUrl('" + urlr + "',this); } else { return false;}\">"
                    + "<img src=\"" + SWBPlatform.getContextPath() + "/swbadmin/images/delete.gif\" border=\"0\" alt=\"" + paramRequest.getLocaleString("remove") + "\"></a>");
            
            //Preview
            SWBResourceURL urlpre = paramRequest.getRenderUrl();
            urlpre.setParameter("suri", id);
            urlpre.setParameter("page", "" + p);
            urlpre.setParameter("sval", postIn.getURI());
            urlpre.setParameter("preview", "true");
            out.println("<a href=\"#\" title=\"" + paramRequest.getLocaleString("previewdocument") + "\" onclick=\"submitUrl('" + urlpre + "',this); return false;\"><img src=\"" + SWBPlatform.getContextPath() + "/swbadmin/icons/preview.gif\" border=\"0\" alt=\"" + paramRequest.getLocaleString("previewdocument") + "\"></a>");
            
            
            //ReClasifyByTpic
            SWBResourceURL urlreClasifybyTopic=paramRequest.getRenderUrl().setMode(Mode_RECLASSBYTOPIC).setCallMethod(SWBResourceURL.Call_DIRECT).setParameter("postUri", postIn.getURI());  
            out.println("<a href=\"#\" title=\"" + paramRequest.getLocaleString("reclasifyByTopic") + "\" onclick=\"showDialog('" + urlreClasifybyTopic + "','" + 
                    paramRequest.getLocaleString("reclasifyByTopic") + "'); return false;\">RT</a>");
            
          
            //ReClasyfyBySentiment & Intensity
            SWBResourceURL urlrev=paramRequest.getRenderUrl().setMode(Mode_RECLASSBYSENTIMENT).setCallMethod(SWBResourceURL.Call_DIRECT).setParameter("postUri", postIn.getURI());  
            out.println("<a href=\"#\" title=\"" + paramRequest.getLocaleString("reeval") + "\" onclick=\"showDialog('" + urlrev + "','" + paramRequest.getLocaleString("reeval") 
                    + "'); return false;\">RV</a>");
            
            //Respond
            if(postIn.getSocialTopic()!=null)
            {
                SWBResourceURL urlresponse=paramRequest.getRenderUrl().setMode(Mode_RESPONSE).setCallMethod(SWBResourceURL.Call_DIRECT).setParameter("postUri", postIn.getURI());  
                out.println("<a href=\"#\" title=\"" + paramRequest.getLocaleString("respond") + "\" onclick=\"showDialog('" + urlresponse + "','" + paramRequest.getLocaleString("respond") 
                        + "'); return false;\">R</a>");
            }
            
            out.println("</td>");
            
            //Show Message
            out.println("<td>");
            out.println(postIn.getMsg_Text());
            out.println("</td>");
            
            
            //Show PostType
            out.println("<td>");
            out.println(postIn instanceof MessageIn?paramRequest.getLocaleString("message"):postIn instanceof PhotoIn?paramRequest.getLocaleString("photo"):postIn instanceof VideoIn?paramRequest.getLocaleString("video"):"---");
            out.println("</td>");
            
            //SocialNetwork
            out.println("<td>");
            out.println(postIn.getPostInSocialNetwork().getDisplayTitle(lang));
            out.println("</td>");
            
            
             //SocialTopic
            out.println("<td>");
            if(postIn.getSocialTopic()!=null)
            {
                out.println(postIn.getSocialTopic().getDisplayTitle(lang));
            }else{
                out.println("---");
            }
            out.println("</td>");
            
              //Show Creation Time
            out.println("<td>");
            out.println(SWBUtils.TEXT.getTimeAgo(postIn.getCreated(), lang));
            out.println("</td>");
            
            //Sentiment
            out.println("<td align=\"center\">");
            if(postIn.getPostSentimentalType()==0)
            {
                out.println("---");
            }else if(postIn.getPostSentimentalType()==1)
            {
                out.println("<img src=\""+SWBPortal.getContextPath()+"/swbadmin/images/feelpos.png"+"\">");
            }else if(postIn.getPostSentimentalType()==2)
            {
                out.println("<img src=\""+SWBPortal.getContextPath()+"/swbadmin/images/feelneg.png"+"\">");
            }else 
            {
                out.println("XXX");
            }
            out.println("</td>");
            
            //Intensity
            out.println("<td>");
            out.println(postIn.getPostIntesityType()==0?paramRequest.getLocaleString("low"):postIn.getPostIntesityType()==1?paramRequest.getLocaleString("medium"):postIn.getPostIntesityType()==2?paramRequest.getLocaleString("high"):"---");
            out.println("</td>");
            
            //Emoticon
            out.println("<td align=\"center\">");
            if(postIn.getPostSentimentalEmoticonType()==1)
            {
                out.println("<img src=\""+SWBPortal.getContextPath()+"/swbadmin/images/emopos.png"+"/>");
            }else if(postIn.getPostSentimentalEmoticonType()==2)
            {
                out.println("<img src=\""+SWBPortal.getContextPath()+"/swbadmin/images/emoneg.png"+"/>");
            }else if(postIn.getPostSentimentalEmoticonType()==0)
            {
                out.println("---");
            }
            out.println("</td>");
            
            
            //Replicas
            out.println("<td align=\"center\">");
            out.println(postIn.getPostRetweets());
            out.println("</td>");
            
            
            //Nunca debería un PostIn no tener un usuario, porque obvio las redes sociales simpre tienen un usuario que escribe los mensajes
            //User
            out.println("<td>");
            out.println(postIn.getPostInSocialNetworkUser()!=null?postIn.getPostInSocialNetworkUser().getSnu_name():paramRequest.getLocaleString("withoutUser"));   //Nunca debería un PostIn no tener un usuario 
            out.println("</td>");
            
            //Followers
            out.println("<td align=\"center\">");
            out.println(postIn.getPostInSocialNetworkUser()!=null?postIn.getPostInSocialNetworkUser().getFollowers():paramRequest.getLocaleString("withoutUser"));
            out.println("</td>");
            
            //Friends
            out.println("<td align=\"center\">");
            out.println(postIn.getPostInSocialNetworkUser()!=null?postIn.getPostInSocialNetworkUser().getFriends():paramRequest.getLocaleString("withoutUser"));
            out.println("</td>");
            
             //Klout
            out.println("<td align=\"center\">");
            out.println(postIn.getPostInSocialNetworkUser()!=null?postIn.getPostInSocialNetworkUser().getSnu_klout():paramRequest.getLocaleString("withoutUser"));
            out.println("</td>");
            
            //Place
            out.println("<td>");
            out.println(postIn.getPostPlace() == null ? "---" : postIn.getPostPlace());
            out.println("</td>");
            
            out.println("<td align=\"center\">");
            out.println(postIn.isIsPrioritary() ? "SI" : "NO");
            out.println("</td>");
            
            
          out.println("</tr>");
        }
        out.println("</tbody>");  
        out.println("</table>");  
        out.println("</fieldset>");
        
        
        if (p > 0 || x < l) //Requiere paginacion
        {
            out.println("<fieldset>");
            out.println("<center>");

            //int pages=(int)(l+ps/2)/ps;

            int pages = (int) (l / ps);
            if ((l % ps) > 0) {
                pages++;
            }

            for (int z = 0; z < pages; z++) {
                SWBResourceURL urlNew = paramRequest.getRenderUrl();
                urlNew.setParameter("suri", id);
                urlNew.setParameter("page", "" + z);
                urlNew.setParameter("search", (searchWord.trim().length() > 0 ? searchWord : ""));
                urlNew.setParameter("orderBy", (request.getParameter("orderBy")!=null && request.getParameter("orderBy").trim().length() > 0 ? request.getParameter("orderBy") : ""));
                if (z != p) {
                    out.println("<a href=\"#\" onclick=\"submitUrl('" + urlNew + "',this); return false;\">" + (z + 1) + "</a> ");
                } else {
                    out.println((z + 1) + " ");
                }
            }
            out.println("</center>");
            out.println("</fieldset>");
        }
        
        out.println("</div>");  
        
        
        if (request.getParameter("preview") != null && request.getParameter("preview").equals("true")) {
            if (request.getParameter("sval") != null) {
                try {
                    doPreview(request, response, paramRequest);
                } catch (Exception e) {
                    out.println("Preview not available...");
                }
            } else {
                out.println("Preview not available...");
            }
        }
     
    }
    
    
     /**
     * Shows the preview of the content.
     *
     * @param request , this holds the parameters
     * @param response , an answer to the user request
     * @param paramRequest , a list of objects like user, webpage, Resource, ...
     * @throws SWBResourceException, a Resource Exception
     * @throws IOException, an In Out Exception
     * @throws SWBResourceException the sWB resource exception
     * @throws IOException Signals that an I/O exception has occurred.
     */
    public void doPreview(HttpServletRequest request, HttpServletResponse response, SWBParamRequest paramRequest) throws SWBResourceException, IOException {
        String postUri=request.getParameter("sval");
        PrintWriter out = response.getWriter();
        out.println("<fieldset>");
        out.println("<legend>" + paramRequest.getLocaleString("previewdocument") + "</legend>");
        try {
            final String path = SWBPlatform.getContextPath() + "/work/models/" + paramRequest.getWebPage().getWebSiteId() + "/jsp/review/showPostIn.jsp";
            if (request != null) {
                RequestDispatcher dis = request.getRequestDispatcher(path);
                if (dis != null) {
                    try {
                        SemanticObject semObject = SemanticObject.createSemanticObject(postUri);
                        request.setAttribute("postIn", semObject);
                        request.setAttribute("paramRequest", paramRequest);
                        dis.include(request, response);
                    } catch (Exception e) {
                        log.error(e);
                        e.printStackTrace(System.out);
                    }
                }
            }
            
            /*
            SWBResource res = SWBPortal.getResourceMgr().getResource(id);
            ((SWBParamRequestImp) paramRequest).setResourceBase(res.getResourceBase());
            res.render(request, response, paramRequest);
            **/
        } catch (Exception e) {
            log.error("Error while getting content string ,id:" + postUri, e);
        }
        out.println("</fieldset>");
    }
    
    
    /*
     * Reclasifica por SocialTopic un PostIn
     */
    private void doReClassifyByTopic(HttpServletRequest request, HttpServletResponse response, SWBParamRequest paramRequest)
    {
        final String path = SWBPlatform.getContextPath() + "/work/models/" + paramRequest.getWebPage().getWebSiteId() + "/jsp/socialTopic/classifybyTopic.jsp";
        RequestDispatcher dis = request.getRequestDispatcher(path);
        if (dis != null) {
            try {
                SemanticObject semObject = SemanticObject.createSemanticObject(request.getParameter("postUri"));
                request.setAttribute("postUri", semObject);
                System.out.println("search en doReClassifyByTopic:"+request.getParameter("search"));
                request.setAttribute("paramRequest", paramRequest);
                dis.include(request, response);
            } catch (Exception e) {
                log.error(e);
            }
        }
    }
    
    /*
     * Reevalua un PostIn en cuanto a sentimiento e intensidad
     */
    
    public void doRevalue(HttpServletRequest request, HttpServletResponse response, SWBParamRequest paramRequest) throws SWBResourceException, IOException {
        response.setContentType("text/html;charset=iso-8859-1");
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("Pragma", "no-cache");
        final String myPath = SWBPlatform.getContextPath() +"/work/models/" + paramRequest.getWebPage().getWebSiteId() + "/jsp/stream/reValue.jsp";
        RequestDispatcher dis = request.getRequestDispatcher(myPath);
        if(dis != null) {
            try {
                SemanticObject semObject = SemanticObject.createSemanticObject(request.getParameter("postUri"));
                request.setAttribute("postUri", semObject);
                request.setAttribute("paramRequest", paramRequest);
                dis.include(request, response);
            } catch (Exception e) {
                log.error(e);
                e.printStackTrace(System.out);
            }
        }
    }
    
    private void doResponse(HttpServletRequest request, HttpServletResponse response, SWBParamRequest paramRequest)
    {
        final String path = SWBPlatform.getContextPath() + "/work/models/" + paramRequest.getWebPage().getWebSiteId() + "/jsp/socialTopic/postInResponse.jsp";
        RequestDispatcher dis = request.getRequestDispatcher(path);
        if (dis != null) {
            try {
                SemanticObject semObject = SemanticObject.createSemanticObject(request.getParameter("postUri"));
                request.setAttribute("postUri", semObject);
                request.setAttribute("paramRequest", paramRequest);
                dis.include(request, response);
            } catch (Exception e) {
                log.error(e);
            }
        }
    }
    
    public void doCreatePost(HttpServletRequest request, HttpServletResponse response, SWBParamRequest paramRequest) throws SWBResourceException, IOException {        
        RequestDispatcher rd = request.getRequestDispatcher(SWBPlatform.getContextPath() +"/work/models/" + paramRequest.getWebPage().getWebSiteId() +"/jsp/post/typeOfContent.jsp");
        request.setAttribute("contentType", request.getParameter("valor"));
        request.setAttribute("wsite", request.getParameter("wsite"));
        request.setAttribute("objUri", request.getParameter("objUri"));
        request.setAttribute("paramRequest", paramRequest);
        
        System.out.println("doCreatePost/1:"+request.getParameter("valor"));
        System.out.println("doCreatePost/2:"+request.getParameter("wsite"));
        System.out.println("doCreatePost/3:"+request.getParameter("objUri"));
        
        
        try {
            rd.include(request, response);
        } catch (ServletException ex) {
            log.error("Error al enviar los datos a typeOfContent.jsp " + ex.getMessage());
        }
    }
    
    
    @Override
    public void processAction(HttpServletRequest request, SWBActionResponse response) throws SWBResourceException, IOException {
        final Resource base = getResourceBase();
        String action = response.getAction();
        System.out.println("Entra a StreamInBox/processA:"+action);
        if(action.equals("changeSocialTopic"))
        {
            if(request.getParameter("postUri")!=null && request.getParameter("newSocialTopic")!=null)
            {
                //System.out.println("processAction/1");
                SemanticObject semObj=SemanticObject.getSemanticObject(request.getParameter("postUri"));
                PostIn post=(PostIn)semObj.createGenericInstance();
                Stream stOld=post.getPostInStream();
                if(request.getParameter("newSocialTopic").equals("none"))
                {
                    post.setSocialTopic(null);
                }else {
                    SemanticObject semObjSocialTopic=SemanticObject.getSemanticObject(request.getParameter("newSocialTopic"));
                    if(semObjSocialTopic!=null)
                    {
                        SocialTopic socialTopic=(SocialTopic)semObjSocialTopic.createGenericInstance();
                        post.setSocialTopic(socialTopic);
                    }
                }
                response.setMode(SWBActionResponse.Mode_EDIT);
                response.setRenderParameter("statusMsg", response.getLocaleString("socialTopicModified"));
                response.setRenderParameter("dialog","close");
                response.setRenderParameter("reloadTap","1");
                response.setRenderParameter("suri", stOld.getURI());
            }
        }else if (action.equals("reValue"))  
        {
            WebSite wsite = base.getWebSite();
            SemanticObject semObj=SemanticObject.getSemanticObject(request.getParameter("postUri"));
            PostIn post=(PostIn)semObj.createGenericInstance();
            Stream stOld=post.getPostInStream();
            try {
                String[] phrases = request.getParameter("fw").split(";");
                ///System.out.println("Entra a processA/reValue-2:"+phrases);
                int nv = Integer.parseInt(request.getParameter("nv"));
                //System.out.println("Entra a processA/reValue-3:"+nv);
                int dpth = Integer.parseInt(request.getParameter("dpth"));
                //System.out.println("Entra a processA/reValue-4:"+dpth);
                SentimentalLearningPhrase slp;
                for (String phrase : phrases) {
                    phrase = phrase.toLowerCase().trim();
                    //System.out.println("Entra a processA/reValue-4.1:"+phrase);
                    phrase = SWBSocialUtil.Classifier.normalizer(phrase).getNormalizedPhrase();
                    //System.out.println("Entra a processA/reValue-4.2--J:"+phrase);
                    phrase = SWBSocialUtil.Classifier.getRootPhrase(phrase);
                    //System.out.println("Entra a processA/reValue-4.3--J:"+phrase);
                    phrase = SWBSocialUtil.Classifier.phonematize(phrase);
                    //System.out.println("Entra a processA/reValue-4.4:"+phrase);
                    slp = SentimentalLearningPhrase.getSentimentalLearningPhrasebyPhrase(phrase, wsite);
                    if (slp == null) {
                        //System.out.println("Entra a processA/reValue-5:"+phrase);
                        phrase = SWBSocialUtil.Classifier.normalizer(phrase).getNormalizedPhrase();
                        phrase = SWBSocialUtil.Classifier.getRootPhrase(phrase);
                        phrase = SWBSocialUtil.Classifier.phonematize(phrase);
                        slp = SentimentalLearningPhrase.ClassMgr.createSentimentalLearningPhrase(wsite);
                        //System.out.println("Entra a processA/reValue-5-1:"+phrase);
                        slp.setPhrase(phrase);
                        slp.setSentimentType(nv);
                        slp.setIntensityType(dpth);
                    } else {
                        //System.out.println("Entra a processA/reValue-6:"+slp);
                        slp.setSentimentType(nv);
                        slp.setIntensityType(dpth);
                    }
                }
                response.setMode(SWBActionResponse.Mode_EDIT);
                response.setRenderParameter("dialog","close");
                response.setRenderParameter("statusMsg", response.getLocaleString("phrasesAdded"));
                //response.setRenderParameter("reloadTap","1");
                response.setRenderParameter("suri", stOld.getURI());
            } catch (Exception e) {
                log.error(e);
            }
        } else if ("remove".equals(action)) //suri, prop
        {
            String sval = request.getParameter("sval");
            SemanticObject so = SemanticObject.createSemanticObject(sval);
            log.debug("processAction(remove PostOut):"+so);
            so.remove();
    
            response.setMode(SWBActionResponse.Mode_EDIT);
            response.setRenderParameter("dialog", "close");
            response.setRenderParameter("suri", request.getParameter("suri"));
            response.setRenderParameter("statusMsg", response.getLocaleString("postDeleted"));
        }else if (action.equals("postMessage") || action.equals("uploadPhoto") || action.equals("uploadVideo")) 
        {
                System.out.println("Entra a Strean_processAction-2:"+request.getParameter("objUri"));
                if(request.getParameter("objUri")!=null)
                {
                    System.out.println("Entra a InBox_processAction-3");
                    PostIn postIn=(PostIn)SemanticObject.getSemanticObject(request.getParameter("objUri")).createGenericInstance();
                    Stream stOld=postIn.getPostInStream(); 
                    SocialNetwork socialNet=(SocialNetwork)SemanticObject.getSemanticObject(request.getParameter("socialNetUri")).createGenericInstance();
                    ArrayList aSocialNets=new ArrayList();
                    aSocialNets.add(socialNet);

                    WebSite wsite=WebSite.ClassMgr.getWebSite(request.getParameter("wsite")); 

                    //En este momento en el siguiente código saco uno de los SocialPFlowRef que tiene el SocialTopic del PostIn que se esta contestando,
                    //Obviamente debo de quitar este código y el SocialPFlowRef debe llegar como parametro, que es de acuerdo al SocialPFlow que el usuario
                    //desee enviar el PostOut que realizó.
                    /**
                    SocialPFlow socialPFlow=null;
                    Iterator<SocialPFlowRef> itflowRefs=socialTopic.listPFlowRefs();
                    while(itflowRefs.hasNext())
                    {
                        SocialPFlowRef socialPflowRef=itflowRefs.next();
                        socialPFlow=socialPflowRef.getPflow();
                    }**/
                    String socialFlow=request.getParameter("socialFlow");
                    SocialPFlow socialPFlow=null;
                    if(socialFlow!=null && socialFlow.trim().length()>0)
                    {
                        socialPFlow=(SocialPFlow)SemanticObject.createSemanticObject(socialFlow).createGenericInstance();
                    }

                    System.out.println("Entra a InBox_processAction-4");
                    SWBSocialUtil.PostOutUtil.sendNewPost(postIn, postIn.getSocialTopic(), socialPFlow, aSocialNets, wsite, request.getParameter("toPost"), request, response);
                    
                    System.out.println("Entra a InBox_processAction-5");
                    response.setMode(SWBActionResponse.Mode_EDIT);
                    response.setRenderParameter("dialog","close");
                    response.setRenderParameter("statusMsg", response.getLocaleString("msgResponseCreated"));
                    response.setRenderParameter("suri", stOld.getURI());
                }
        }
         
    }
    
}
