<%-- 
    Document   : pieGender
    Created on : 03-oct-2013, 19:51:58
    Author     : gabriela.rosales
--%>

<%@page import="java.text.SimpleDateFormat"%>
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
    JSONArray getObject(SemanticObject semObj, String lang, String filter, String sinceDateAnalysis, String toDateAnalysis) throws Exception {

        int female = 0, male = 0, other = 0;
        int totalPost = 0;
        ArrayList genderMale = new ArrayList();
        ArrayList genderFemale = new ArrayList();
        ArrayList genderother = new ArrayList();
        Iterator<PostIn> itObjPostIns = null;
        
        SimpleDateFormat formatDate = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat formatTo = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date sinDateAnalysis = null;
        Date tDateAnalysis = null;
        if(sinceDateAnalysis != null && toDateAnalysis != null) {
            try {
                sinDateAnalysis = formatDate.parse(sinceDateAnalysis);
            } catch (java.text.ParseException e) {
            }
            try {
                toDateAnalysis += " 23:59:59";
                tDateAnalysis = formatTo.parse(toDateAnalysis);
            } catch(java.text.ParseException e) {
            }
        }

        if (semObj.getGenericInstance() instanceof Stream) {
            Stream stream = (Stream) semObj.getGenericInstance();
            itObjPostIns = stream.listPostInStreamInvs();
        } else if (semObj.getGenericInstance() instanceof SocialTopic) {
            SocialTopic socialTopic = (SocialTopic) semObj.getGenericInstance();
            itObjPostIns = PostIn.ClassMgr.listPostInBySocialTopic(socialTopic, socialTopic.getSocialSite());
        }
        if(sinDateAnalysis != null && tDateAnalysis != null) {
            itObjPostIns = SWBSocialResUtil.Util.getFilterDates(itObjPostIns, sinDateAnalysis, tDateAnalysis);
        }

        while (itObjPostIns.hasNext()) {
            PostIn postIn = itObjPostIns.next();
            if(postIn.getPostInSocialNetworkUser()!=null)
            {
                totalPost++;
                //System.out.println("postIn.getPostInSocialNetworkUser().getSnu_gender()"+postIn.getPostInSocialNetworkUser().getSnu_gender());
                if (postIn.getPostInSocialNetworkUser().getSnu_gender() == SocialNetworkUser.USER_GENDER_MALE) {
                    male++;
                    genderMale.add(postIn);
                } else if (postIn.getPostInSocialNetworkUser().getSnu_gender() == SocialNetworkUser.USER_GENDER_FEMALE) {
                    female++;
                    genderFemale.add(postIn);
                } else if (postIn.getPostInSocialNetworkUser().getSnu_gender() == SocialNetworkUser.USER_GENDER_UNDEFINED || postIn.getPostInSocialNetworkUser().getSnu_gender() == 0) {
                    other++;
                    genderother.add(postIn);
                }
            }
        }
        //this is a quick fix to show the graph and don't show a empty blank space
        //when there is no data. It returns 'Sin Datos' message and a new variable: 'emptyData'
        //used to display or not the Zero values below each icon below the graph.
        if(totalPost == 0){
            JSONArray arr = new JSONArray();
            JSONObject node0 = new JSONObject();
            node0.put("color", "#E6E6E6");
            node0.put("chartclass", "neuClass");
            node0.put("label", "Sin Datos");
            node0.put("value1", "0");
            node0.put("value2", "100");
            node0.put("emptyData", "true");
            arr.put(node0);
            return arr;
        }
        Iterator gMale = genderMale.iterator();
        int neutralsMale = 0, positivesMale = 0, negativesMale = 0, totalMale = 0;
        while (gMale.hasNext()) {
            PostIn postIn = (PostIn) gMale.next();
            totalMale++;
            if (postIn.getPostSentimentalType() == 0) {
                neutralsMale++;
            } else if (postIn.getPostSentimentalType() == 1) {
                positivesMale++;
            } else if (postIn.getPostSentimentalType() == 2) {
                negativesMale++;
            }
        }

        Iterator gFemale = genderFemale.iterator();
        int neutralsFemale = 0, positivesFemale = 0, negativesFemale = 0, totalFemale = 0;
        while (gFemale.hasNext()) {
            PostIn postIn = (PostIn) gFemale.next();
            totalFemale++;
            if (postIn.getPostSentimentalType() == 0) {
                neutralsFemale++;
            } else if (postIn.getPostSentimentalType() == 1) {
                positivesFemale++;
            } else if (postIn.getPostSentimentalType() == 2) {
                negativesFemale++;
            }
        }

        Iterator gOther = genderother.iterator();
        int neutralsOther = 0, positivesOther = 0, negativesOther = 0, totalOther = 0;


        while (gOther.hasNext()) {
            PostIn postIn = (PostIn) gOther.next();
            totalOther++;
            if (postIn.getPostSentimentalType() == 0) {
                neutralsOther++;
            } else if (postIn.getPostSentimentalType() == 1) {
                positivesOther++;
            } else if (postIn.getPostSentimentalType() == 2) {
                negativesOther++;
            }
        }

        int totalPositives = positivesMale + positivesFemale + positivesOther;
        int totalNegatives = negativesMale + negativesFemale + negativesOther;
        int totalNeutrals = neutralsMale + neutralsFemale + neutralsOther;
        JSONArray node = new JSONArray();

        //if (male > 0) {
        //System.out.println("FILTRO:" + filter);
        if (filter.equals("all")) {
            float intTotalVotos = male + female + other;
            float intPorcentajeMale = 0;
            float intPorcentajeFemale = 0;
            float intPorcentajeOther = 0;
            if (totalPost != 0) {
                intPorcentajeMale = ((float) male * 100) / (float) totalPost;
                intPorcentajeFemale = ((float) female * 100) / (float) totalPost;
                intPorcentajeOther = ((float) other * 100) / (float) totalPost;
            }


            JSONObject node1 = new JSONObject();
            node1.put("label", SWBSocialResUtil.Util.getStringFromGenericLocale("male", lang));
            node1.put("value1", "" + male);
            node1.put("value2", "" + round(intPorcentajeMale));
            JSONObject jor = new JSONObject();
            jor.put("positivos", "" + positivesMale);
            jor.put("negativos", "" + negativesMale);
            jor.put("neutros", "" + neutralsMale);
            node1.put("valor", jor);
            if (positivesMale > negativesMale && positivesMale > neutralsMale) {
                node1.put("color", "#008000");
            } else if (negativesMale > neutralsMale) {
                node1.put("color", "#FF0000");
            } else {
                node1.put("color", "#838383");
            }
            node1.put("label2", SWBSocialResUtil.Util.getStringFromGenericLocale("male", lang) + ": " + male + "     -     " + SWBSocialResUtil.Util.getStringFromGenericLocale("positives", lang) + " : " + positivesMale + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("negatives", lang) + " :" + negativesMale + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang) + " : " + neutralsMale);
            node1.put("chartclass", "possClass");
            JSONObject joTotal = new JSONObject();
            joTotal.put("positivos", "" + totalPositives);
            joTotal.put("negativos", "" + totalNegatives);
            joTotal.put("neutros", "" + totalNeutrals);
            node1.put("label3", joTotal);
            node.put(node1);
            //}

            // if (female > 0) {
            JSONObject node2 = new JSONObject();
            node2.put("label", SWBSocialResUtil.Util.getStringFromGenericLocale("female", lang));
            node2.put("value1", "" + female);
            node2.put("value2", "" + round(intPorcentajeFemale));
            JSONObject joc = new JSONObject();
            joc.put("positivos", "" + positivesFemale);
            joc.put("negativos", "" + negativesFemale);
            joc.put("neutros", "" + neutralsFemale);
            node2.put("valor", joc);
            if (positivesFemale > negativesFemale && positivesFemale > neutralsFemale) {
                node2.put("color", "#008000");
            } else if (negativesFemale > neutralsFemale) {
                node2.put("color", "#FF0000");
            } else {
                node2.put("color", "#838383");
            }
            node2.put("label2", SWBSocialResUtil.Util.getStringFromGenericLocale("female", lang) + ": " + female + "     -     " + SWBSocialResUtil.Util.getStringFromGenericLocale("positives", lang) + " : " + positivesFemale + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("negatives", lang) + " :" + negativesFemale + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang) + " : " + neutralsFemale);
            node2.put("chartclass", "possClass");
            node2.put("label3", "Total de Post: " + totalPost);
            node.put(node2);


            //}

            //if (other > 0) {
            JSONObject node3 = new JSONObject();
            node3.put("label", SWBSocialResUtil.Util.getStringFromGenericLocale("nodefine", lang));
            node3.put("value1", "" + other);
            node3.put("value2", "" + round(intPorcentajeOther));
            JSONObject jo = new JSONObject();
            jo.put("positivos", "" + positivesOther);
            jo.put("negativos", "" + negativesOther);
            jo.put("neutros", "" + neutralsOther);
            node3.put("valor", jo);
            if (positivesOther > negativesOther && positivesOther > neutralsOther) {
                node3.put("color", "#008000");
            } else if (negativesOther > neutralsOther) {
                node3.put("color", "#FF0000");
            } else {
                node3.put("color", "#838383");
            }
            node3.put("label2", SWBSocialResUtil.Util.getStringFromGenericLocale("nodefine", lang) + ": " + other + "     -     " + SWBSocialResUtil.Util.getStringFromGenericLocale("positives", lang) + "  : " + positivesOther + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("negatives", lang) + "  :" + negativesOther + " " + SWBSocialResUtil.Util.getStringFromGenericLocale("neutral", lang) + " : " + neutralsOther);
            node3.put("chartclass", "possClass");
            node3.put("label3", "Total de Post: " + totalPost);
            node.put(node3);


            // }
        } else if (filter.equals("male")) {


            float intPorcentajeNeutralsMale = 0;
            float intPorcentajePositivesMale = 0;
            float intPorcentajeNegativesMale = 0;
            if (totalMale != 0) {
                intPorcentajeNeutralsMale = ((float) neutralsMale * 100) / (float) totalMale;
                intPorcentajePositivesMale = ((float) positivesMale * 100) / (float) totalMale;
                intPorcentajeNegativesMale = ((float) negativesMale * 100) / (float) totalMale;
            }

            if (negativesMale == 0 && positivesMale == 0 && neutralsMale == 0) {
                JSONObject node3 = new JSONObject();
                node3.put("label", "Sin Datos");
                node3.put("value1", "0");
                node3.put("value2", "100");
                node3.put("color", "#E6E6E6");
                node3.put("chartclass", "neuClass");
                node.put(node3);
                return node;
            }

            if (neutralsMale > 0) {
                JSONObject node4 = new JSONObject();
                node4.put("label", "Neutros");
                node4.put("value1", "" + neutralsMale);
                node4.put("value2", "" + round(intPorcentajeNeutralsMale));
                node4.put("color", "#838383");
                node4.put("label2", "");
                node4.put("chartclass", "possClass");
                node4.put("label3", "");
                node.put(node4);
            }

            if (positivesMale > 0) {
                JSONObject node5 = new JSONObject();
                node5.put("label", "Positivos");
                node5.put("value1", "" + positivesMale);
                node5.put("value2", "" + round(intPorcentajePositivesMale));
                node5.put("color", "#008000");
                node5.put("label2", "");
                node5.put("chartclass", "possClass");
                node5.put("label3", "");
                node.put(node5);
            }

            if (negativesMale > 0) {
                JSONObject node6 = new JSONObject();
                node6.put("label", "Negativos");
                node6.put("value1", "" + negativesMale);
                node6.put("value2", "" + round(intPorcentajeNegativesMale));
                node6.put("color", "#FF0000");
                node6.put("label2", "");
                node6.put("chartclass", "possClass");
                node6.put("label3", "");
                node.put(node6);
            }

        } else if (filter.equals("female")) {

            float intPorcentajeNeutralsFemale = 0;
            float intPorcentajePositivesFemale = 0;
            float intPorcentajeNegativesFemale = 0;
            if (totalFemale != 0) {
                intPorcentajeNeutralsFemale = ((float) neutralsFemale * 100) / (float) totalFemale;
                intPorcentajePositivesFemale = ((float) positivesFemale * 100) / (float) totalFemale;
                intPorcentajeNegativesFemale = ((float) negativesFemale * 100) / (float) totalFemale;
            }


            if (negativesFemale == 0 && positivesFemale == 0 && neutralsFemale == 0) {
                JSONObject node3 = new JSONObject();
                node3.put("label", "Sin Datos");
                node3.put("value1", "0");
                node3.put("value2", "100");
                node3.put("color", "#E6E6E6");
                node3.put("chartclass", "neuClass");
                node.put(node3);
                return node;
            }

            if (neutralsFemale > 0) {
                JSONObject node4 = new JSONObject();
                node4.put("label", "Neutros");
                node4.put("value1", "" + neutralsFemale);
                node4.put("value2", "" + round(intPorcentajeNeutralsFemale));
                node4.put("color", "#838383");
                node4.put("label2", "");
                node4.put("chartclass", "possClass");
                node4.put("label3", "");
                node.put(node4);
            }

            if (positivesFemale > 0) {
                JSONObject node5 = new JSONObject();
                node5.put("label", "Positivos");
                node5.put("value1", "" + positivesFemale);
                node5.put("value2", "" + round(intPorcentajePositivesFemale));
                node5.put("color", "#008000");
                node5.put("label2", "");
                node5.put("chartclass", "possClass");
                node5.put("label3", "");
                node.put(node5);
            }

            if (negativesFemale > 0) {
                JSONObject node6 = new JSONObject();
                node6.put("label", "Negativos");
                node6.put("value1", "" + negativesFemale);
                node6.put("value2", "" + round(intPorcentajeNegativesFemale));
                node6.put("color", "#FF0000");
                node6.put("label2", "");
                node6.put("chartclass", "possClass");
                node6.put("label3", "");
                node.put(node6);
            }



        } else if (filter.equals("nodefine")) {

            float intPorcentajeNeutralsNodefine = 0;
            float intPorcentajePositivesNodefine = 0;
            float intPorcentajeNegativesNodefine = 0;
            if (totalOther != 0) {
                intPorcentajeNeutralsNodefine = ((float) neutralsOther * 100) / (float) totalOther;
                intPorcentajePositivesNodefine = ((float) positivesOther * 100) / (float) totalOther;
                intPorcentajeNegativesNodefine = ((float) negativesOther * 100) / (float) totalOther;
            }

            if (negativesOther == 0 && positivesOther == 0 && neutralsOther == 0) {
                JSONObject node3 = new JSONObject();
                node3.put("label", "Sin Datos");
                node3.put("value1", "0");
                node3.put("value2", "100");
                node3.put("color", "#E6E6E6");
                node3.put("chartclass", "neuClass");
                node.put(node3);
                return node;
            }

            if (neutralsOther > 0) {
                JSONObject node4 = new JSONObject();
                node4.put("label", "Neutros");
                node4.put("value1", "" + neutralsOther);
                node4.put("value2", "" + round(intPorcentajeNeutralsNodefine));
                node4.put("color", "#838383");
                node4.put("label2", "");
                node4.put("chartclass", "possClass");
                node4.put("label3", "");
                node.put(node4);

            }
            if (positivesOther > 0) {
                JSONObject node5 = new JSONObject();
                node5.put("label", "Positivos");
                node5.put("value1", "" + positivesOther);
                node5.put("value2", "" + round(intPorcentajePositivesNodefine));
                node5.put("color", "#008000");
                node5.put("label2", "");
                node5.put("chartclass", "possClass");
                node5.put("label3", "Total de Post: " + totalPost);
                node.put(node5);
            }

            if (negativesOther > 0) {
                JSONObject node6 = new JSONObject();
                node6.put("label", "Negativos");
                node6.put("value1", "" + negativesOther);
                node6.put("value2", "" + round(intPorcentajeNegativesNodefine));
                node6.put("color", "#FF0000");
                node6.put("label2", "");
                node6.put("chartclass", "possClass");
                node6.put("label3", "");
                node.put(node6);
            }


        }
        //System.out.println("node en gender \n" + node + "\n");
        return node;
    }

    public double round(float number) {
        return Math.rint(number * 100) / 100;
    }
%>
<%

    if (request.getParameter("objUri") != null) {
        SemanticObject semObj = SemanticObject.getSemanticObject(request.getParameter("objUri"));
        String clsName = semObj.createGenericInstance().getClass().getName();
        String lang = request.getParameter("lang");
        String filter = request.getParameter("filter");
        String sinceDate = request.getParameter("sinceDateAnalysisPieCharts" + clsName + semObj.getId());
        String toDate = request.getParameter("toDateAnalysisPieCharts" + clsName + semObj.getId());        
        // System.out.println("filter" + filter);
        out.println(getObject(semObj, lang, filter, sinceDate , toDate));
    }
%>