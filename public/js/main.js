function select_click_bets() {
   filterselect = document.getElementById('filter1')
   value = filterselect.options[filterselect.selectedIndex].value
   $.ajax({
   type: "GET",
   data: "viewingfilter="+value,
   url: '/bets',
   success: function(data, type, xmlhttp){
     $("#div_bets").html(data);
   }
  });
}

function select_click_issues() {
   filterselect = document.getElementById('filter1')
   value = filterselect.options[filterselect.selectedIndex].value
   $.ajax({
   type: "GET",
   data: "viewingfilter="+value,
   url: '/issues',
   success: function(data, type, xmlhttp){
     $("#div_issues").html(data);
   }
  });
}

function setnavigation() {
  url = document.location.href;
  var navelement;
  if (url.indexOf('home') != -1) {
    navelement = document.getElementById('a_home');
    navelement.style.background="#E0EFFD";
  } else if (url.indexOf('bets') != -1) {
    navelement = document.getElementById('a_bets');
    navelement.style.background="#E0EFFD";
  } else if (url.indexOf('issues') != -1) {
    navelement = document.getElementById('a_issues');
    navelement.style.background="#E0EFFD";
  } else if (url.indexOf('members') != -1) {
    navelement = document.getElementById('a_members');
    navelement.style.background="#E0EFFD";
  } else if (url.indexOf('top') != -1) {
    navelement = document.getElementById('a_top');
    navelement.style.background="#E0EFFD";
  } else if (url.indexOf('login') != -1) {
    navelement = document.getElementById('a_login');
    navelement.style.background="#E0EFFD";
  }

  if (navelement)
    navelement.style.color="#000";
}
