//= require whurl_engine/jquery-1-7-1-min
//= require whurl_engine/jquery-ui-1-8-16-min
//= require whurl_engine/jquery-ujs
//= require whurl_engine/jquery-livequery

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


function Whurl($whurlForm) {
    this.$whurlForm = $whurlForm;
    var self = this;

    $('.add_header', this.$whurlForm).click(function () {
        self.addInputs('header');
    });

    $('.add_param', this.$whurlForm).click(function () {
        self.addInputs('param');
    });

    $('.delete_header', this.$whurlForm).live('click', function (e) {
        //e.currentTarget
        self.deleteHeader(this);
    });

     $('.delete_param', this.$whurlForm).live('click', function (e) {
        //e.currentTarget
        self.deleteParam(this);
    });

    $(".trash_headers", this.$whurlForm).click(function () {
        self.trashHeaders();
    });

    $(".trash_queries", self.$whurlForm).click(function () {
        self.trashQueries();
    });

    $('.header_pair input.value', this.$whurlForm).live('focusin', (function () {
        if ($('.header_pair:last input', self.$whurlForm).val() != "") {
            self.addInputs('header');
        }
    }));

    $('.param_pair input.value', this.$whurlForm).live('focusin', (function () {
        if ($('.param_pair:last input', self.$whurlForm).val() != "") {
            self.addInputs('param');
        }
    }));

    $('.url select', this.$whurlForm).change(function () {
        self.updateBodyInput();
    });

    $(".header_pair input.key", this.$whurlForm).livequery(function() {
        $(this).autocomplete({source:headers});
    });

    $(".clear_fields", this.$whurlForm).click(function () {
        $("input[type=text], textarea", self.$whurlForm).val("");
        self.trashHeaders();
        self.trashQueries();
    });

    this.addInputs = function (type) {
        var $fields = $('.' + type + '_pair', this.$whurlForm).first().clone();
        $fields.children('input').val("").attr('disabled', false);
        $fields.hide().appendTo(this.$whurlForm.find('.' + type + 's')).slideDown('fast');
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
        $(".header_pair:visible", self.$whurlForm).each(function (i, element) {
            $(element).slideUp(function () {
                $(element).remove();
            });
        });
        this.addInputs('header');
    };

    this.trashQueries = function () {
        $(".param_pair:visible", self.$whurlForm).each(function (i, element) {
            $(element).slideUp(function () {
                $(element).remove();
            });
        });
        this.addInputs('param');
    };

    this.updateBodyInput = function () {
        var method = $('.url select', self.$whurlForm).val();
        if ($.inArray(method, ["PUT", "POST"]) > -1) {
            $('#whurl_request_body', self.$whurlForm).attr('disabled', false).removeClass('textarea_disabled');
        } else {
            $('#whurl_request_body', self.$whurlForm).attr('disabled', true).addClass('textarea_disabled');
        }
    };
    this.updateBodyInput();
}
