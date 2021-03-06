<%-- 
    Document   : showFastCalendar
    Created on : 15-nov-2013, 12:29:53
    Author     : jorge.jimenez
--%>

<%@page import="org.semanticwb.SWBPortal"%> 
<%@page import="org.semanticwb.platform.SemanticObject"%>
<%@page contentType="text/html" pageEncoding="ISO-8859-1"%>
<%@page import="org.semanticwb.social.*"%>
<%@page import="java.util.Iterator"%>
<%@page import="org.semanticwb.SWBUtils"%>
<%@page import="org.semanticwb.model.*"%>
<%@page import="org.semanticwb.platform.SemanticProperty"%>
<%@page import="org.semanticwb.portal.api.*"%>
<%@page import="org.semanticwb.*"%>
<%@page import="org.semanticwb.social.util.*"%>
<%@page import="java.util.*"%>
<jsp:useBean id="paramRequest" scope="request" type="org.semanticwb.portal.api.SWBParamRequest"/>
<%@page import="org.semanticwb.social.admin.resources.util.SWBSocialResUtil"%>

<%
    //System.out.println("mostrando calendario");
    if (request.getAttribute("postOut") == null) {
        return;
    }

    SemanticObject semObj = (SemanticObject) request.getAttribute("postOut");
    if (semObj == null) {
        return;
    }
    WebSite wsite = WebSite.ClassMgr.getWebSite(semObj.getModel().getName());
    if (wsite == null) {
        return;
    }

    PostOut postOut = (PostOut) semObj.getGenericInstance();
    
    if(postOut.getFastCalendar()!=null)
    {
        User user=paramRequest.getUser(); 
        
        FastCalendar fastCalendar=postOut.getFastCalendar();
        Date inidate=fastCalendar.getFc_date();
        //System.out.println("inidate:"+inidate);
        StringTokenizer st = new StringTokenizer(inidate.toString(), "-");
        String nf = inidate.toString();
        String y = "";
        String m = "";
        String d = "";
        if (st.hasMoreTokens()) {
            y = st.nextToken();
            if (st.hasMoreTokens()) {
                m = st.nextToken();
            }
            if (st.hasMoreTokens()) {
                d = st.nextToken();
                int pos=-1;
                pos=d.indexOf(" ");
                if(pos>-1)
                {
                    d=d.substring(0, pos);
                }
            }
            nf = y + "-" + m + "-" + d;
        }
        //System.out.println("nf:"+nf);
        //java.util.Calendar cal = java.util.Calendar.getInstance();  
        //cal.setTime(inidate);
        //System.out.println("inidate Year:"+inidate.getYear()+",inidate Month:"+inidate.getMonth()+",inidate Day:"+inidate.getDay()+",inidate Min:"+inidate.getMinutes());
        //System.out.println(cal.);
        SWBResourceURL urlAction = paramRequest.getActionUrl();
        urlAction.setParameter("postOut", postOut.getURI());
        
        //Current date and time
        Date todayDate = new Date();
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(todayDate);
        int currentYear = cal.get(java.util.Calendar.YEAR);
        int currentMonth = cal.get(java.util.Calendar.MONTH) + 1;
        int currentDay = cal.get(java.util.Calendar.DAY_OF_MONTH);
        int currentHour = cal.get(java.util.Calendar.HOUR_OF_DAY);
        int currentMin = cal.get(java.util.Calendar.MINUTE);
        %>
        <div class="msgFastCalendar">
            <p id="msgTitle">Programar env&iacute;o de mensaje</p>
            <form id="<%=postOut.getId()%>/removeFastCalendarForm" dojoType="dijit.form.Form" class="swbform" method="post" action="<%=urlAction.setAction("uploadFastCalendar")%>" method="post" onsubmit="submitForm('<%=postOut.getId()%>/removeFastCalendarForm'); return false;"> 
            </form>
            <form id="<%=postOut.getId()%>/uploadFastCalendarForm" dojoType="dijit.form.Form" class="swbform" method="post" action="<%=urlAction.setAction("uploadFastCalendar")%>" method="post" onsubmit="submitForm('<%=postOut.getId()%>/uploadFastCalendarForm'); return false;"> 
            <%
                String minutes="00";
                if(inidate.getMinutes()!=0) minutes=""+inidate.getMinutes(); 
                String hour=""+inidate.getHours();
                if(hour.length()==1) hour="0"+hour; 
                String starthour=hour+":"+minutes;
                //System.out.println("Final starthour:"+starthour);
            %>
                <input type="hidden" id="<%=semObj.getId()%>_today_hidden" name="today_hidden" value="<%=currentYear+"-" +currentMonth+"-"+currentDay%>"/>
                D&iacute;a:<input type="text" name="postOut_inidate" id="<%=semObj.getId()%>_inidate" dojoType="dijit.form.DateTextBox"  size="11" style="width:110px;" hasDownArrow="true" value="<%=nf%>" constraints="{min:'<%=currentYear%>-<%=String.format("%02d", currentMonth)%>-<%=String.format("%02d", currentDay)%>'}" onchange="removeMin(this, '<%=semObj.getId()%>_postOut_starthour_<%=starthour%>', document.getElementById('<%=semObj.getId()%>_today_hidden').value, '<%=currentHour%>', '<%=currentMin%>');"> 
                Hora:<input dojoType="dijit.form.TimeTextBox" name="postOut_starthour" id="<%=semObj.getId()%>_postOut_starthour_<%=starthour%>" value="<%=(starthour!=null&&starthour.trim().length() > 0 ? "T"+starthour+":00" : "T00:00:00")%>" constraints=constraints={formatLength:'short',selector:'timeOnly',timePattern:'HH:mm',min:'T<%=String.format("%02d", currentHour)%>:<%=String.format("%02d", currentMin)%>:00'} />
                <p><button dojoType="dijit.form.Button" id="sendButton" type="submit" ><%=paramRequest.getLocaleString("btnSend")%></button>
                    <button dojoType="dijit.form.Button" type="button" onClick="submitForm('<%=postOut.getId()%>/removeFastCalendarForm'); return false;"><%=SWBSocialResUtil.Util.getStringFromGenericLocale("removeCal", user.getLanguage())%></button>
                </p>
            </form>
        </div>      
            <script type="text/javascript">
                function setDefaultValues()  
                {
                    var forma=document.forms["<%=postOut.getId()%>/uploadFastCalendarForm"];
                    forma.postOut_inidate.value="";
                    forma.postOut_starthour.value="";
                    return true;
                }
            </script>
       <%         
    }else{
        %>
            Ooopss!!, This PostOut doesn't have a Fast Calendar attached..
        <%
    }
%>

<script>
    //dojo.addOnLoad(
        //function(){
            //var dojoObj = dijit.byId('widget_<%//=semObj.getId()%>_postOut_starthour_<%//=starthour%>');
            //console.log('widget_<%//=semObj.getId()%>_postOut_starthour_<%//=starthour%>');
            //var i = 0;                      
        //}
    //);
   
    /*
    setTimeout(function(){document.getElementById('sendButton').focus();
                              //alert('hi');
                              var dojoObj = dijit.byId('<%//=semObj.getId()%>_inidate');
                              var tmp = dojoObj.value;                              
                              dojoObj.attr('value', '');
                              dojoObj.attr('value', tmp);
                             }, 500);
    */    
</script>