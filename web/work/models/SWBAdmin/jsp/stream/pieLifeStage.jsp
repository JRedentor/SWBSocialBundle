<%-- 
    Document   : profileGeoLocation
    Created on : 07-oct-2013, 19:51:58
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
    JSONArray getObject(SemanticObject semObj, String lang, String idModel) throws Exception {

        int young = 0, child = 0, teenAge = 0, youngAdult = 0, adult = 0, thirdAge = 0, totalPost = 0, nodefined =0;
        Iterator<PostIn> itObjPostIns = null;
        if (semObj.getGenericInstance() instanceof Stream) {
            Stream stream = (Stream) semObj.getGenericInstance();
            itObjPostIns = stream.listPostInStreamInvs();
        } else if (semObj.getGenericInstance() instanceof SocialTopic) {
            SocialTopic socialTopic = (SocialTopic) semObj.getGenericInstance();
            itObjPostIns = PostIn.ClassMgr.listPostInBySocialTopic(socialTopic, socialTopic.getSocialSite());
        }


        ArrayList youngArray = new ArrayList();
        ArrayList childArray = new ArrayList();
        ArrayList teenAgeArray = new ArrayList();
        ArrayList youngAdultArray = new ArrayList();
        ArrayList thirdAgeArray = new ArrayList();
        ArrayList adultArray = new ArrayList();
        ArrayList noDefine = new ArrayList();
        String youngTitle = "Young";
        String youngAdultTitle = "YoungAdult";
        String childTitle = "Child";
        String teenTitle = "TeenAge";
        String adultTitle = "Adult";
        String thirdTitle = "ThirdAge";

        while (itObjPostIns.hasNext()) {
            PostIn postIn = itObjPostIns.next();
            totalPost++;
            if (postIn.getPostInSocialNetworkUser().getSnu_LifeStage() == null) {
                nodefined++;
                noDefine.add(postIn);                
            } else if (postIn.getPostInSocialNetworkUser().getSnu_LifeStage().getId().equals("Young")) {
                young++;
                youngArray.add(postIn);
                //youngTitle = postIn.getPostInSocialNetworkUser().getSnu_LifeStage().getTitle(lang);
            } else if (postIn.getPostInSocialNetworkUser().getSnu_LifeStage().getId().equals("Child")) {
                child++;
                childArray.add(postIn);
                //childTitle = postIn.getPostInSocialNetworkUser().getSnu_LifeStage().getTitle(lang);
            } else if (postIn.getPostInSocialNetworkUser().getSnu_LifeStage().getId().equals("TeenAge")) {
                teenAge++;
                teenAgeArray.add(postIn);
                //teenTitle = postIn.getPostInSocialNetworkUser().getSnu_LifeStage().getTitle(lang);
            } else if (postIn.getPostInSocialNetworkUser().getSnu_LifeStage().getId().equals("YoungAdult")) {
                youngAdult++;
                youngAdultArray.add(postIn);
                //youngAdultTitle = postIn.getPostInSocialNetworkUser().getSnu_LifeStage().getTitle(lang);
            } else if (postIn.getPostInSocialNetworkUser().getSnu_LifeStage().getId().equals("Adult")) {
                adult++;
                adultArray.add(postIn);
                //adultTitle = postIn.getPostInSocialNetworkUser().getSnu_LifeStage().getTitle(lang);
            } else if (postIn.getPostInSocialNetworkUser().getSnu_LifeStage().getId().equals("ThirdAge")) {
                thirdAge++;
                thirdAgeArray.add(postIn);
                //thirdTitle = postIn.getPostInSocialNetworkUser().getSnu_LifeStage().getTitle(lang);
            }

        }
        Iterator noDefined = noDefine.iterator();

        int neutralsnoDefine = 0, positivesnoDefine = 0, negativesnoDefine = 0;
        while (noDefined.hasNext()) {
            PostIn pi = (PostIn) noDefined.next();
            if (pi.getPostSentimentalType() == 0) {
                neutralsnoDefine++;
            } else if (pi.getPostSentimentalType() == 1) {
                positivesnoDefine++;
            } else if (pi.getPostSentimentalType() == 2) {
                negativesnoDefine++;
            }
        }
        


        Iterator youngI = youngArray.iterator();

        int neutralsYoung = 0, positivesYoung = 0, negativesYoung = 0;
        while (youngI.hasNext()) {
            PostIn pi = (PostIn) youngI.next();
            if (pi.getPostSentimentalType() == 0) {
                neutralsYoung++;
            } else if (pi.getPostSentimentalType() == 1) {
                positivesYoung++;
            } else if (pi.getPostSentimentalType() == 2) {
                negativesYoung++;
            }
        }


        Iterator childI = childArray.iterator();

        int neutralsChild = 0, positivesChild = 0, negativesChild = 0;
        while (childI.hasNext()) {
            PostIn pi = (PostIn) childI.next();
            if (pi.getPostSentimentalType() == 0) {
                neutralsChild++;
            } else if (pi.getPostSentimentalType() == 1) {
                positivesChild++;
            } else if (pi.getPostSentimentalType() == 2) {
                negativesChild++;
            }
        }

        Iterator teenAgeI = teenAgeArray.iterator();

        int neutralsteenAge = 0, positivesteenAge = 0, negativesteenAge = 0;
        while (teenAgeI.hasNext()) {
            PostIn pi = (PostIn) teenAgeI.next();
            if (pi.getPostSentimentalType() == 0) {
                neutralsteenAge++;
            } else if (pi.getPostSentimentalType() == 1) {
                positivesteenAge++;
            } else if (pi.getPostSentimentalType() == 2) {
                negativesteenAge++;
            }
        }


        Iterator youngAdultI = youngAdultArray.iterator();

        int neutralsyoungAdult = 0, positivesyoungAdult = 0, negativesyoungAdult = 0;
        while (youngAdultI.hasNext()) {
            PostIn pi = (PostIn) youngAdultI.next();
            if (pi.getPostSentimentalType() == 0) {
                neutralsyoungAdult++;
            } else if (pi.getPostSentimentalType() == 1) {
                positivesyoungAdult++;
            } else if (pi.getPostSentimentalType() == 2) {
                negativesyoungAdult++;
            }
        }

        Iterator adultI = adultArray.iterator();

        int neutralsAdult = 0, positivesAdult = 0, negativesAdult = 0;
        while (adultI.hasNext()) {
            PostIn pi = (PostIn) adultI.next();
            if (pi.getPostSentimentalType() == 0) {
                neutralsAdult++;
            } else if (pi.getPostSentimentalType() == 1) {
                positivesAdult++;
            } else if (pi.getPostSentimentalType() == 2) {
                negativesAdult++;
            }
        }

        Iterator thirdAgeI = thirdAgeArray.iterator();

        int neutralsthirdAge = 0, positivesthirdAge = 0, negativesthirdAge = 0;
        while (thirdAgeI.hasNext()) {
            PostIn pi = (PostIn) thirdAgeI.next();
            if (pi.getPostSentimentalType() == 0) {
                neutralsthirdAge++;
            } else if (pi.getPostSentimentalType() == 1) {
                positivesthirdAge++;
            } else if (pi.getPostSentimentalType() == 2) {
                negativesthirdAge++;
            }
        }


        float intTotalVotos = young + child + teenAge + youngAdult + adult + thirdAge;

        //Positivo
        float intPorcentajenodefined = ((float) nodefined * 100) / (float) totalPost;
        
        float intPorcentajeYoung = ((float) young * 100) / (float) totalPost;

        //System.out.println("Votos Positivos:"+positives+", porcentaje:"+intPorcentajePositive); 

        //Negativo
        float intPorcentajeChild = ((float) child * 100) / (float) totalPost;

        //System.out.println("Votos negatives"+negatives+", porcentaje:"+intPorcentajeNegative); 

        //Neutro
        float intPorcentajeTeenAge = ((float) teenAge * 100) / (float) totalPost;

        float intPorcentajeYoungAdult = ((float) youngAdult * 100) / (float) totalPost;

        //System.out.println("Votos neutrals"+neutrals+", porcentaje:"+intPorcentajeNeutral);         

        float intPorcentajeAdult = ((float) adult * 100) / (float) totalPost;
        float intPorcentajeThirdAge = ((float) thirdAge * 100) / (float) totalPost;

        JSONArray node = new JSONArray();


        if (child > 0) {

            JSONObject node1 = new JSONObject();
            node1.put("label", childTitle);
            node1.put("value1", "" + child);
            node1.put("value2", "" + round(intPorcentajeChild));
            if (positivesChild > negativesChild && positivesChild > neutralsChild) {
                node1.put("color", "#86c440");
            } else if (negativesChild > neutralsChild) {
                node1.put("color", "#990000");
            } else {
                node1.put("color", "#eae8e3");
            }
            node1.put("label2", childTitle + " " + child + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("positives", lang) + " : " + positivesChild + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("negatives", lang) + " : " + negativesChild + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang) + " : " + neutralsChild);
            node1.put("chartclass", "possClass");
            node1.put("label3", "Total de Post: " + totalPost);

            node.put(node1);
        }


        if (young > 0) {
            JSONObject node2 = new JSONObject();
            node2.put("label", youngTitle);
            node2.put("value1", "" + young);
            node2.put("value2", "" + round(intPorcentajeYoung));
            if (positivesYoung > negativesYoung && positivesYoung > neutralsYoung) {
                node2.put("color", "#86c440");
            } else if (negativesYoung > neutralsYoung) {
                node2.put("color", "#990000");
            } else {
                node2.put("color", "#eae8e3");
            }
            node2.put("label2", youngTitle + " " + young + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("positives", lang) + " : " + positivesYoung + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("negatives", lang) + " : " + negativesYoung + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang) + " : " + neutralsYoung);
            node2.put("chartclass", "possClass");
            node2.put("label3", "Total de Post: " + totalPost);

            node.put(node2);
        }


        if (teenAge > 0) {
            JSONObject node3 = new JSONObject();
            node3.put("label", teenTitle);
            node3.put("value1", "" + teenAge);
            node3.put("value2", "" + round(intPorcentajeTeenAge));
            if (positivesteenAge > negativesteenAge && positivesteenAge > neutralsteenAge) {
                node3.put("color", "#86c440");
            } else if (negativesteenAge > neutralsteenAge) {
                node3.put("color", "#990000");
            } else {
                node3.put("color", "#eae8e3");
            }
            node3.put("label2", teenTitle + " " + teenAge + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("positives", lang) + " : " + positivesteenAge + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("negatives", lang) + " : " + negativesteenAge + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang) + " : " + neutralsteenAge);
            node3.put("chartclass", "possClass");
            node3.put("label3", "Total de Post: " + totalPost);

            node.put(node3);
        }

        if (youngAdult > 0) {
            JSONObject node4 = new JSONObject();
            node4.put("label", youngAdultTitle);
            node4.put("value1", "" + youngAdult);
            node4.put("value2", "" + round(intPorcentajeYoungAdult));
            if (positivesyoungAdult > negativesyoungAdult && positivesyoungAdult > neutralsyoungAdult) {
                node4.put("color", "#86c440");
            } else if (negativesyoungAdult > neutralsyoungAdult) {
                node4.put("color", "#990000");
            } else {
                node4.put("color", "#eae8e3");
            }
            node4.put("label2", youngAdultTitle + "  " + youngAdult + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("positives", lang) + " : " + positivesyoungAdult + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("negatives", lang) + " : " + negativesyoungAdult + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang) + " : " + neutralsyoungAdult);
            node4.put("chartclass", "possClass");
            node4.put("label3", "Total de Post: " + totalPost);

            node.put(node4);
        }


        if (adult > 0) {
            JSONObject node5 = new JSONObject();
            node5.put("label", adultTitle);
            node5.put("value1", "" + adult);
            node5.put("value2", "" + round(intPorcentajeAdult));
            if (positivesAdult > negativesAdult && positivesAdult > neutralsAdult) {
                node5.put("color", "#86c440");
            } else if (negativesAdult > neutralsAdult) {
                node5.put("color", "#990000");
            } else {
                node5.put("color", "#eae8e3");
            }
            node5.put("label2", adultTitle + " " + adult + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("positives", lang) + " : " + positivesAdult + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("negatives", lang) + " : " + negativesAdult + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang) + " : " + neutralsAdult);
            node5.put("chartclass", "possClass");
            node5.put("label3", "Total de Post: " + totalPost);

            node.put(node5);
        }


        if (thirdAge > 0) {
            JSONObject node6 = new JSONObject();
            node6.put("label", thirdTitle);
            node6.put("value1", "" + thirdAge);
            node6.put("value2", "" + round(intPorcentajeThirdAge));
            if (positivesthirdAge > negativesthirdAge && positivesthirdAge > neutralsthirdAge) {
                node6.put("color", "#86c440");
            } else if (negativesthirdAge > neutralsthirdAge) {
                node6.put("color", "#990000");
            } else {
                node6.put("color", "#eae8e3");
            }
            node6.put("label2", thirdTitle + " " + thirdAge + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("positives", lang) + " : " + positivesthirdAge + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("negatives", lang) + " : " + negativesthirdAge + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang) + " : " + neutralsthirdAge);
            node6.put("chartclass", "possClass");
            node6.put("label3", "Total de Post: " + totalPost);

            node.put(node6);
        }


        if (child == 0 && young == 0 && teenAge == 0 && youngAdult == 0 && adult == 0 && thirdAge == 0) {

            JSONObject node3 = new JSONObject();
            node3.put("label", SWBSocialResUtil.Util.getStringFromGenericLocale("nodefined", lang));
            node3.put("value1", "0");
            node3.put("value2", ""+round(intPorcentajenodefined));
            if (positivesnoDefine > negativesnoDefine && positivesnoDefine > neutralsnoDefine) {
                node3.put("color", "#86c440");
            } else if (negativesnoDefine > neutralsnoDefine) {
                node3.put("color", "#990000");
            } else {
                node3.put("color", "#eae8e3");
            }
            node3.put("chartclass", "neuClass");
            node3.put("label2", SWBSocialResUtil.Util.getStringFromGenericLocale("nodefined", lang)+ " " + SWBSocialResUtil.Util.getStringFromGenericLocale("positives", lang) + " : " + positivesnoDefine + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("negatives", lang) + " : " + negativesnoDefine + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang) + " : " + neutralsnoDefine);
            node3.put("label3", "Total de Post: " + totalPost);

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
        String idModel = request.getParameter("idModel");
        out.println(getObject(semObj, lang, idModel));
    }
%>