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


function Wurl(wurlForm) {
    this.$wurlForm = $(wurlForm);

	var $textArea = this.$wurlForm.siblings('.response.body').find('textarea');
	$textArea.val(JSON.stringify(JSON.parse($textArea.val()), undefined, 2));
    this.codeMirror = CodeMirror.fromTextArea($textArea[0], {
        "json":true,
        'readOnly':"nocursor",
        "mode":'javascript',
        "json": true,
        'lineNumbers':true
    });

    var self = this;

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

    this.queryParams = function() {
		var toReturn = [];
        $(".param_pair:visible", self.$wurlForm).each(function (i, element) {
            paramKey = $(element).find('input.key').val();
            paramValue = $(element).find('input.value').val();
			if (paramKey.length && paramValue.length) {
				toReturn.push(paramKey + '=' + paramValue);
			}	
        });
        return toReturn;
	};

    this.getData = function () {
        var method = $('#wurl_request_method', self.$wurlForm).val();
        if ($.inArray(method, ["PUT", "POST", "DELETE"]) > -1) {
            return $('#wurl_request_body', self.$wurlForm).val()
        } else {
			return self.queryParams().join("\n");
        }
    };

	this.url = function () {
		var url = $('#wurl_request_url', self.$wurlForm).val();
		var method = $('#wurl_request_method', self.$wurlForm).val();
		var params = self.queryParams().join("&")
		if ($.inArray(method, ["PUT", "POST", "DELETE"]) > -1 && params.length) {
			url += "?" + params;
		}
		return url;
	}

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
                var $status = self.$wurlForm.siblings('.response.status');
                var $body = self.$wurlForm.siblings('.response.body');
                $status.html(jqXHR.status + ' ' + jqXHR.statusText).effect("highlight", {}, 3000);
                self.codeMirror.setValue(JSON.stringify(JSON.parse(jqXHR.responseText), undefined, 2));
                $body.effect("highlight", {}, 3000);
            }
        });
    };
}

$(function () {
    $('.wurl_form').each(function (index, wurlForm) {
        wurl = new Wurl(wurlForm);
    });
});