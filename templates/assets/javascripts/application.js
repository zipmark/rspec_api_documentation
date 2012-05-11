var headers = ["Accept",
  "Accept-Charset",
  "Accept-Encoding",
  "Accept-Language",
  "Authorization",
  "Cache-Control",
  "Connection",
  "Cookie",
  "Content-Length",
  "Content-MD5",
  "Content-Type",
  "Date",
  "Expect",
  "From",
  "Host",
  "If-Match",
  "If-Modified-Since",
  "If-None-Match",
  "If-Range",
  "If-Unmodified-Since",
  "Max-Forwards",
  "Pragma",
  "Proxy-Authorization",
  "Range",
  "Referer",
  "TE",
  "Upgrade",
  "User-Agent",
  "Via",
  "Warning"];

function mirror(textarea, contentType, options) {
  $textarea = $(textarea);
  if ($textarea.val() != '') {
    if(contentType.indexOf('json') >= 0) {
      $textarea.val(JSON.stringify(JSON.parse($textarea.val()), undefined, 2));
      options.json = true;
      options.mode = 'javascript';
    } else if (contentType.indexOf('javascript') >= 0) {
      options.mode = 'javascript';
    } else if (contentType.indexOf('xml') >= 0) {
      options.mode = 'xml';
    } else {
      options.mode = 'htmlmixed';
    }
  }
  return CodeMirror.fromTextArea(textarea, options);
};

function Wurl(wurlForm) {
  this.$wurlForm = $(wurlForm);
  var self = this;

  this.requestBodyMirror = mirror(this.$wurlForm.find('.post_body textarea')[0], $('.request.content_type', this.$wurlForm).val(), {})
  this.responseBodyMirror = mirror(this.$wurlForm.find('.response.body textarea')[0], $('.response.content_type', this.$wurlForm).val(), { "readOnly": true, "lineNumbers":true});

  $('.give_it_a_wurl', this.$wurlForm).click(function (event) {
    event.preventDefault();
    self.sendWurl();
  });
  $('.add_header', this.$wurlForm).click(function () {
    self.addInputs('header');
  });

  $('.add_param', this.$wurlForm).click(function () {
    self.addInputs('param');
  });

  $('.delete_header', this.$wurlForm).live('click', function (e) {
    self.deleteHeader(this);
  });

  $('.delete_param', this.$wurlForm).live('click', function (e) {
    self.deleteParam(this);
  });

  $(".trash_headers", this.$wurlForm).click(function () {
    self.trashHeaders();
  });

  $(".trash_queries", self.$wurlForm).click(function () {
    self.trashQueries();
  });

  $('.header_pair input.value', this.$wurlForm).live('focusin', (function () {
    if ($('.header_pair:last input', self.$wurlForm).val() != "") {
      self.addInputs('header');
    }
  }));

  $('.param_pair input.value', this.$wurlForm).live('focusin', (function () {
    if ($('.param_pair:last input', self.$wurlForm).val() != "") {
      self.addInputs('param');
    }
  }));

  $('.url select', this.$wurlForm).change(function () {
    self.updateBodyInput();
  });

  $(".header_pair input.key", this.$wurlForm).livequery(function () {
    $(this).autocomplete({source:headers});
  });

  $(".clear_fields", this.$wurlForm).click(function () {
    $("input[type=text], textarea", self.$wurlForm).val("");
    self.trashHeaders();
    self.trashQueries();
  });

  this.addInputs = function (type) {
    var $fields = $('.' + type + '_pair', this.$wurlForm).first().clone();
    $fields.children('input').val("").attr('disabled', false);
    $fields.hide().appendTo(this.$wurlForm.find('.' + type + 's')).slideDown('fast');
  };

  this.deleteHeader = function (element) {
    var $fields = $(element).closest(".header_pair");
    $fields.slideUp(function () {
      $fields.remove();
    });
  };

  this.deleteParam = function (element) {
    var $fields = $(element).closest(".param_pair");
    $fields.slideUp(function () {
      $paramFields.remove();
    });
  };

  this.trashHeaders = function () {
    $(".header_pair:visible", self.$wurlForm).each(function (i, element) {
      $(element).slideUp(function () {
        $(element).remove();
      });
    });
    this.addInputs('header');
  };

  this.trashQueries = function () {
    $(".param_pair:visible", self.$wurlForm).each(function (i, element) {
      $(element).slideUp(function () {
        $(element).remove();
      });
    });
    this.addInputs('param');
  };

  this.updateBodyInput = function () {
    var method = $('#wurl_request_method', self.$wurlForm).val();
    if ($.inArray(method, ["PUT", "POST", "DELETE"]) > -1) {
      $('#wurl_request_body', self.$wurlForm).attr('disabled', false).removeClass('textarea_disabled');
    } else {
      $('#wurl_request_body', self.$wurlForm).attr('disabled', true).addClass('textarea_disabled');
    }
  };
  this.updateBodyInput();

  this.makeBasicAuth = function () {
    var user = $('#wurl_basic_auth_user', this.$wurlForm).val();
    var password = $('#wurl_basic_auth_password', this.$wurlForm).val();
    var token = user + ':' + password;
    var hash = $.base64.encode(token);
    return "Basic " + hash;
  };

  this.queryParams = function () {
    var toReturn = [];
    $(".param_pair:visible", self.$wurlForm).each(function (i, element) {
      paramKey = $(element).find('input.key').val();
      paramValue = $(element).find('input.value').val();
      if (paramKey.length && paramValue.length) {
        toReturn.push(paramKey + '=' + paramValue);
      }
    });
    return toReturn.join("&");
  };

  this.getData = function () {
    var method = $('#wurl_request_method', self.$wurlForm).val();
    if ($.inArray(method, ["PUT", "POST", "DELETE"]) > -1) {
      self.requestBodyMirror.save();
      return self.requestBodyMirror.getValue();
    } else {
      return self.queryParams();
    }
  };

  this.url = function () {
    var url = $('#wurl_request_url', self.$wurlForm).val();
    var method = $('#wurl_request_method', self.$wurlForm).val();
    var params = self.queryParams();
    if ($.inArray(method, ["PUT", "POST", "DELETE"]) > -1 && params.length) {
      url += "?" + params;
    }
    return url[0] == '/' ? url : '/' + url;
  };

  this.sendWurl = function () {
    $.ajax({
      beforeSend:function (req) {
        $(".header_pair:visible", self.$wurlForm).each(function (i, element) {
          headerKey = $(element).find('input.key').val();
          headerValue = $(element).find('input.value').val();
          req.setRequestHeader(headerKey, headerValue);
        });
        req.setRequestHeader('Authorization', self.makeBasicAuth());
      },
      type:$('#wurl_request_method', self.$wurlForm).val(),
      url:this.url(),
      data:this.getData(),
      complete:function (jqXHR) {
        var $status = $('.response.status', self.$wurlForm);
        $status.html(jqXHR.status + ' ' + jqXHR.statusText);

        $('.response.headers', self.$wurlForm).html(jqXHR.getAllResponseHeaders());

        contentType = jqXHR.getResponseHeader("content-type");
        if (contentType.indexOf('json') >= 0 && jqXHR.responseText.length > 1) {
          self.responseBodyMirror.setValue(JSON.stringify(JSON.parse(jqXHR.responseText), undefined, 2));
          self.responseBodyMirror.setOption('mode', 'javascript');
          self.responseBodyMirror.setOption('json', true);
        } else if (contentType.indexOf('javascript') >= 0) {
          self.responseBodyMirror.setValue(jqXHR.responseText);
          self.responseBodyMirror.setOption('mode', 'javascript');
        } else if (contentType.indexOf('xml') >= 0) {
          self.responseBodyMirror.setValue(jqXHR.responseText);
          self.responseBodyMirror.setOption('mode', 'xml');
        } else {
          self.responseBodyMirror.setValue(jqXHR.responseText);
          self.responseBodyMirror.setOption('mode', 'htmlmixed');
        }
        $('.response', self.$wurlForm).effect("highlight", {}, 3000);
        $('html,body').animate({ scrollTop:$('a.response_anchor', self.$wurlForm).offset().top }, { duration:'slow', easing:'swing'});
      }
    });
  };
}

$(function () {
  $('.wurl_form').each(function (index, wurlForm) {
    wurl = new Wurl(wurlForm);
  });

  var $textAreas = $('.request.body textarea');
  $textAreas.each(function(i, textarea) {
    var contentType = $(textarea).parents('div.request').find('.request.content_type').val();
    mirror(textarea, contentType, {"readOnly":true, "lineNumbers": true});
  });
});
