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


function Wurl($wurlForm) {
    this.$wurlForm = $wurlForm;
    var self = this;

    $('.add_header', this.$wurlForm).click(function () {
        self.addInputs('header');
    });

    $('.add_param', this.$wurlForm).click(function () {
        self.addInputs('param');
    });

    $('.delete_header', this.$wurlForm).live('click', function (e) {
        //e.currentTarget
        self.deleteHeader(this);
    });

     $('.delete_param', this.$wurlForm).live('click', function (e) {
        //e.currentTarget
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

    $(".header_pair input.key", this.$wurlForm).livequery(function() {
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
        var method = $('.url select', self.$wurlForm).val();
        if ($.inArray(method, ["PUT", "POST"]) > -1) {
            $('#wurl_request_body', self.$wurlForm).attr('disabled', false).removeClass('textarea_disabled');
        } else {
            $('#wurl_request_body', self.$wurlForm).attr('disabled', true).addClass('textarea_disabled');
        }
    };
    this.updateBodyInput();
}
