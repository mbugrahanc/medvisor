<%-- //[START all]--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%-- //[START imports]--%>
<%@ page import="com.example.guestbook.UserComplaint" %>
<%@ page import="com.example.guestbook.UserInfo" %>
<%@ page import="com.googlecode.objectify.Key" %>
<%@ page import="com.googlecode.objectify.ObjectifyService" %>
<%-- //[END imports]--%>

<%@ page import="java.util.List" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>
</head>

<body>

<%
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    if (user != null) {
        pageContext.setAttribute("user", user);
    
%>

<p>Welcome, ${fn:escapeXml(user.nickname)}! (You can
    <a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)</p>

    <form action="/sign" method="post">
        <div><textarea name="content" rows="3" cols="60" placeholder="What's the matter?"></textarea></div>
        <div><input type="submit" value="Post complaint"/></div>
        <!-- <input type="hidden" name="guestbookName" value="${fn:escapeXml(guestbookName)}"/> -->
    </form>

<%-- //[START datastore]--%>
<%
        // Create the correct Ancestor key
        Key<UserInfo> userEmail = Key.create(UserInfo.class, user.getEmail());

        // Run an ancestor query to ensure we see the most up-to-date
        // view of the Greetings belonging to the selected Guestbook.
        List<UserComplaint> userComplaints = ObjectifyService.ofy()
              .load()
              .type(UserComplaint.class) // We want only users
              .ancestor(userEmail)  // Anyone with this email
              .order("-date")       // Most recent first - date is indexed.
              .list();

        if (userComplaints.isEmpty()) {
%>
<p>'${fn:escapeXml(user.nickname)}', you have no complaints.</p>
<%
        } else {
%>
<p>Your complaints are:</p>
<%
            // Look at all of our greetings
            for (UserComplaint userComplaint : userComplaints) {
                pageContext.setAttribute("userComplaint_content", userComplaint.content);
%>
<p></p>
<blockquote>${fn:escapeXml(userComplaint_content)}</blockquote>
<%
            }
        }
%>
<%-- //[END datastore]--%>
<% 
    } else {
%>
<p>Please
    <a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
    to use our service.</p>
<%
    }
%>

</body>
</html>
<%-- //[END all]--%>