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
    var self = this;

    $('.give_it_a_whurl', this.$wurlForm).click(function (event) {
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
        var method = $('#whurl_request_method', self.$wurlForm).val();
        if ($.inArray(method, ["PUT", "POST"]) > -1) {
            $('#whurl_request_body', self.$wurlForm).attr('disabled', false).removeClass('textarea_disabled');
        } else {
            $('#whurl_request_body', self.$wurlForm).attr('disabled', true).addClass('textarea_disabled');
        }
    };
    this.updateBodyInput();

    this.makeBasicAuth = function () {
        var user = $('#whurl_basic_auth_user', this.$wurlForm).val();
        var password = $('#whurl_basic_auth_password', this.$wurlForm).val();
        var token = user + ':' + password;
        var hash = $.base64.encode(token);
        return "Basic " + hash;
    };

    this.getData = function () {
        var method = $('#whurl_request_method', self.$wurlForm).val();
        if ($.inArray(method, ["PUT", "POST"]) > -1) {
            return $('#whurl_request_body', self.$wurlForm).val()
        } else {
            var toReturn = "";
            $(".param_pair:visible", self.$wurlForm).each(function (i, element) {
                paramKey = $(element).find('input.key').val();
                paramValue = $(element).find('input.value').val();
                toReturn += headerKey + '=' + headerValue + "\n";
            });
            return toReturn;
        }
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
            type:$('#whurl_request_method', self.$wurlForm).val(),
            url:$('#whurl_request_url', self.$whurlForm).val(),
            data:this.getData(),
            complete:function (jqXHR) {
                console.log(jqXHR);
                $('.response_status', self.$wurlForm).html(jqXHR.status + ' - ' + jqXHR.statusText);
                $('.response_body', self.$wurlForm).html(jqXHR.responseText);
            }
        });
    };
}

$(function () {
    $('.whurl_form').each(function (index, wurlForm) {
        wurl = new Wurl(wurlForm);
    });
});
