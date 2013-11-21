<%-- 
    Document   : pieGender
    Created on : 03-oct-2013, 19:51:58
    Author     : gabriela.rosales
--%>

<%@page import="org.semanticwb.social.admin.resources.util.SWBSocialResUtil"%>
<%@page contentType="text/json" pageEncoding="UTF-8"%> 
<%@page import="org.semanticwb.social.util.SWBSocialUtil"%>
<%@page import="org.semanticwb.platform.SemanticObject"%>
<%@page import="org.semanticwb.social.*"%>
<%@page import="java.util.Iterator"%>
<%@page import="org.semanticwb.SWBUtils"%>
<%@page import="org.semanticwb.model.*"%>
<%@page import="org.semanticwb.SWBPortal"%> 
<%@page import="org.semanticwb.platform.SemanticProperty"%>
<%@page import="org.semanticwb.portal.api.*"%>
<%@page import="org.json.*"%>
<%@page import="java.util.*"%> 


<%!
    JSONArray getObject(SemanticObject semObj, String lang) throws Exception {

        int female = 0, male = 0, other = 0;
        int totalPost =0;
        ArrayList genderMale = new ArrayList();
        ArrayList genderFemale = new ArrayList();
        ArrayList genderother = new ArrayList();
        Iterator<PostIn> itObjPostIns = null;

        if (semObj.getGenericInstance() instanceof Stream) {
            Stream stream = (Stream) semObj.getGenericInstance();
            itObjPostIns = stream.listPostInStreamInvs();
        } else if (semObj.getGenericInstance() instanceof SocialTopic) {            
            SocialTopic socialTopic = (SocialTopic) semObj.getGenericInstance();
            itObjPostIns = PostIn.ClassMgr.listPostInBySocialTopic(socialTopic, socialTopic.getSocialSite());
        }
        while (itObjPostIns.hasNext()) {
            PostIn postIn = itObjPostIns.next();
            totalPost++;
            //System.out.println("postIn.getPostInSocialNetworkUser().getSnu_gender()"+postIn.getPostInSocialNetworkUser().getSnu_gender());
            if (postIn.getPostInSocialNetworkUser().getSnu_gender() == SocialNetworkUser.USER_GENDER_MALE) {
                male++;
                genderMale.add(postIn);
            } else if (postIn.getPostInSocialNetworkUser().getSnu_gender() == SocialNetworkUser.USER_GENDER_FEMALE) {
                female++;
                genderFemale.add(postIn);
            } else if (postIn.getPostInSocialNetworkUser().getSnu_gender() == SocialNetworkUser.USER_GENDER_UNDEFINED || postIn.getPostInSocialNetworkUser().getSnu_gender()==0) {
                other++;
                genderother.add(postIn);
            }
           
        }

        Iterator gMale = genderMale.iterator();
        int neutralsMale = 0, positivesMale = 0, negativesMale = 0;

        while (gMale.hasNext()) {
            PostIn postIn = (PostIn) gMale.next();
            if (postIn.getPostSentimentalType() == 0) {
                neutralsMale++;
            } else if (postIn.getPostSentimentalType() == 1) {
                positivesMale++;
            } else if (postIn.getPostSentimentalType() == 2) {
                negativesMale++;
            }
        }


        Iterator gFemale = genderFemale.iterator();
        int neutralsFemale = 0, positivesFemale = 0, negativesFemale = 0;
        while (gFemale.hasNext()) {
            PostIn postIn = (PostIn) gFemale.next();
            if (postIn.getPostSentimentalType() == 0) {
                neutralsFemale++;
            } else if (postIn.getPostSentimentalType() == 1) {
                positivesFemale++;
            } else if (postIn.getPostSentimentalType() == 2) {
                negativesFemale++;
            }
        }


        Iterator gOther = genderother.iterator();
        int neutralsOther = 0, positivesOther = 0, negativesOther = 0;


        while (gOther.hasNext()) {
            PostIn postIn = (PostIn) gOther.next();
            if (postIn.getPostSentimentalType() == 0) {
                neutralsOther++;
            } else if (postIn.getPostSentimentalType() == 1) {
                positivesOther++;
            } else if (postIn.getPostSentimentalType() == 2) {
                negativesOther++;
            }
        }

        float intTotalVotos = male + female + other;

        //Positivo
        float intPorcentajeMale = ((float) male * 100) / (float) totalPost;

        //System.out.println("Votos Positivos:"+positives+", porcentaje:"+intPorcentajePositive); 

        //Negativo
        float intPorcentajeFemale = ((float) female * 100) / (float) totalPost;

        //System.out.println("Votos negatives"+negatives+", porcentaje:"+intPorcentajeNegative); 

        //Neutro
        float intPorcentajeOther = ((float) other * 100) / (float) totalPost;

        JSONArray node = new JSONArray();

        if (male > 0) {

            JSONObject node1 = new JSONObject();
            node1.put("label", SWBSocialResUtil.Util.getStringFromGenericLocale("male", lang));
            node1.put("value1", "" + male);
            node1.put("value2", "" + round(intPorcentajeMale));

            if (positivesMale > negativesMale && positivesMale > neutralsMale) {
                node1.put("color", "#86c440");
            } else if (negativesMale > neutralsMale) {
                node1.put("color", "#990000");
            } else {
                node1.put("color", "#eae8e3");
            }
            node1.put("label2", SWBSocialResUtil.Util.getStringFromGenericLocale("male", lang) + ": " + male + "     -     " +SWBSocialResUtil.Util.getStringFromGenericLocale("positives", lang) + " : " + positivesMale +  " " +SWBSocialResUtil.Util.getStringFromGenericLocale("negatives", lang) + " :" + negativesMale + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang) + " : " + neutralsMale);
            node1.put("chartclass", "possClass");
            node1.put("label3", "Total de Post:"+totalPost);
            node.put(node1);
        }

        if (female > 0) {
            JSONObject node2 = new JSONObject();
            node2.put("label", SWBSocialResUtil.Util.getStringFromGenericLocale("female", lang));
            node2.put("value1", "" + female);
            node2.put("value2", "" + round(intPorcentajeFemale));
            if (positivesFemale > negativesFemale && positivesFemale > neutralsFemale) {
                node2.put("color", "#86c440");
            } else if (negativesFemale > neutralsFemale) {
                node2.put("color", "#990000");
            } else {
                node2.put("color", "#eae8e3");
            }
            node2.put("label2", SWBSocialResUtil.Util.getStringFromGenericLocale("female", lang) + ": " + female + "     -     " + SWBSocialResUtil.Util.getStringFromGenericLocale("positives", lang) + " : " + positivesFemale + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("negatives", lang) + " :" + negativesFemale +  " " +SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang) + " : " + neutralsFemale);
            node2.put("chartclass", "possClass");
            node2.put("label3", "Total de Post: "+totalPost);
            node.put(node2);
            

        }

        if (other > 0) {
            JSONObject node3 = new JSONObject();
            node3.put("label", SWBSocialResUtil.Util.getStringFromGenericLocale("nodefine", lang));
            node3.put("value1", "" + other);
            node3.put("value2", "" + round(intPorcentajeOther));

            if (positivesOther > negativesOther && positivesOther > neutralsOther) {
                node3.put("color", "#86c440");
            } else if (negativesOther > neutralsOther) {
                node3.put("color", "#990000");
            } else {
                node3.put("color", "#eae8e3");
            }
            node3.put("label2", SWBSocialResUtil.Util.getStringFromGenericLocale("nodefine", lang) + ": " + other + "     -     " + SWBSocialResUtil.Util.getStringFromGenericLocale("positives", lang) + "  : " + positivesOther +  " " +SWBSocialResUtil.Util.getStringFromGenericLocale("negatives", lang) + "  :" + negativesOther +  " " + SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang) + " : " + neutralsOther);
            node3.put("chartclass", "possClass");
             node3.put("label3", "Total de Post: "+totalPost);
            node.put(node3);
                        

        }

        if (male == 0 && female == 0 && other == 0) {

            JSONObject node3 = new JSONObject();
            node3.put("label", SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang));
            node3.put("value1", "0");
            node3.put("value2", "100");
            node3.put("color", "#eae8e3");
            node3.put("chartclass", "neuClass");
            node3.put("label2", "Sin datos para procesar");
            node3.put("label3", "Total de Post: "+totalPost);
            node.put(node3);

        }


        return node;
    }

    public double round(float number) {
        return Math.rint(number * 100) / 100;
    }
%>
<%
    if (request.getParameter("objUri") != null) {
        SemanticObject semObj = SemanticObject.getSemanticObject(request.getParameter("objUri"));
        String lang = request.getParameter("lang");
        out.println(getObject(semObj, lang));
    }
%>