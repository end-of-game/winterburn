<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://java.sun.com/jsf/html"
	xmlns:f="http://java.sun.com/jsf/core"
	xmlns:ui="http://java.sun.com/jsf/facelets">

<h:head>
	<meta charset="utf-8"></meta>
	<title>Files Generator</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0"></meta>
	<meta name="description" content=""></meta>
	<meta name="author" content=""></meta>
	<link href="../css/bootstrap.css" rel="stylesheet"></link>
	<style>
body {
	padding-top: 60px;
	/* 60px to make the container go all the way to the bottom of the topbar */
}
</style>
	<link href="../css/bootstrap-responsive.css" rel="stylesheet"></link>

	<!--[if lt IE 9]>
      <script src="../assets/js/html5shiv.js"></script>
    <![endif]-->
	<link rel="apple-touch-icon-precomposed"
		href="../ico/apple-touch-icon-144-precomposed.png"></link>
	<link rel="apple-touch-icon-precomposed"
		href="../ico/apple-touch-icon-114-precomposed.png"></link>
	<link rel="apple-touch-icon-precomposed"
		href="../ico/apple-touch-icon-72-precomposed.png"></link>
	<link rel="apple-touch-icon-precomposed"
		href="../ico/apple-touch-icon-57-precomposed.png"></link>
	<link rel="shortcut icon" href="../ico/favicon.png"></link>
</h:head>

<h:body>


	<div class="navbar navbar-inverse navbar-fixed-top">
		<div class="navbar-inner">
			<div class="container">
				<button type="button" class="btn btn-navbar" data-toggle="collapse"
					data-target=".nav-collapse">
					<span class="icon-bar"></span> <span class="icon-bar"></span> <span
						class="icon-bar"></span>
				</button>
				<a class="brand" href="#">Files Generator</a>
				<div class="nav-collapse collapse">
					<ul class="nav">
						<li><a><b>Pages générées :</b></a> </li>
						<#list entities?keys as entity>
						<li><a href="../pages/${entity}.jsf">${entity}</a></li>
						</#list>
					</ul>
				</div>
				<!--/.nav-collapse -->
			</div>
		</div>
	</div>

	<div class="container">
		<!-- BODY -->
		<ui:insert name="body" />
	</div>


	<script src="../js/jquery.js"></script>
	<script src="../js/bootstrap-transition.js"></script>
	<script src="../js/bootstrap-alert.js"></script>
	<script src="../js/bootstrap-modal.js"></script>
	<script src="../js/bootstrap-dropdown.js"></script>
	<script src="../js/bootstrap-scrollspy.js"></script>
	<script src="../js/bootstrap-tab.js"></script>
	<script src="../js/bootstrap-tooltip.js"></script>
	<script src="../js/bootstrap-popover.js"></script>
	<script src="../js/bootstrap-button.js"></script>
	<script src="../js/bootstrap-collapse.js"></script>
	<script src="../js/bootstrap-carousel.js"></script>
	<script src="../js/bootstrap-typeahead.js"></script>
	
	
</h:body>
</html>