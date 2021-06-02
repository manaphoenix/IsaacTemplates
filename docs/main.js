$(function() {
  $("#navigation").load("/IsaacTemplates/nav.html");
  $("#footer").load("/IsaacTemplates/footer.html");
  $("#header").load("/IsaacTemplates/header.html", function() {
    $("#menu")[0].addEventListener("click", function() {
      this.classList.toggle("active");
      var content = $("#navigation")[0];
      if (content.style.display === "none") {
        content.style.display = "block";
      } else {
        content.style.display = "none";
      }
    });
  });
});