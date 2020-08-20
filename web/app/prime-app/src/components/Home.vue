<template>
    <div class="hello">
        <a href="/"><h1>Prime Generator</h1></a>
        <div class="blurb">
            <div>The quick and simple prime sampling</div>
        </div>
        <div id="content">
            <div id="hr" class="human-readable" style="">
                <p>
                    {{ largestPrime }}
                </p>
            </div>
            <div class="text-editor">
                <input id="input" type="text" value="" class=""
                       v-model.lazy="upperBound"
                       @blur="$v.upperBound.$touch()">
                <template v-if="$v.upperBound.$error">
                    <span v-if="!$v.upperBound.mustBeNumber" class="warning text-highlight">The input must be numeric</span>
                </template>
            </div>
            <div class="part-explanation">
                <p class="cron-parts">
                <div><span class="clickable" @click="takePrime">The Largest Prime</span></div>
            </div>
            <div class="warning"></div>
        </div>
    </div>
</template>

<script lang="ts">
import { Vue } from 'vue-property-decorator';
// eslint-disable-next-line no-unused-vars
import {Prime} from "@/types";
import PrimeService from "../services/PrimeService";
import { validationMixin } from 'vuelidate';
import { numeric } from 'vuelidate/lib/validators';

export default Vue.extend({
    data() {
        return {
            prime: {} as Prime, // Declaring reactive data as type User
            upperBound: {} as string,
            error: {} as string
        }
    },
    mixins: [validationMixin],
    validations: {
        upperBound: { numeric },
    },
    mounted() {
        this.prime = {
            value: "0",
            elasedTime: "0"
        };
        this.upperBound = "0"
    },
    computed :{
        largestPrime(): string {
            return this.prime.value
        }
    },
    methods: {
        takePrime() : void {
            this.$v.upperBound.$touch()
            if (this.$v.upperBound.$invalid) {
                return
            } else {
                this.$v.$reset()
            }
            PrimeService.get(this.upperBound).then( res => this.prime.value = res.data.number).catch( err => (err))
        }
    }
})
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
    *,
    *::before,
    *::after {
        box-sizing: border-box;
    }
    ::-moz-selection {
        background-color: rgba(255, 255, 128, 0.2);
    }
    ::selection {
        background-color: rgba(255, 255, 128, 0.2);
    }
    html {
        color: #cccccc;
        background-color: #1a1a1a;
        text-align: center;
        font-family: "Courier New", Courier, monospace;
        font-size: 1.25em;
    }
    body {
        max-width: 900px;
        margin: 1em auto;
        padding: 0 1em;
    }
    a,
    a:visited,
    a.active {
        color: #cccccc;
    }
    h1,
    .logo-guru {
        color: #ffff80;
        font-weight: 100;
        margin-bottom: 0.2em;
        margin-top: 0.2em;
        font-size: 2em;
        display: inline-block;
    }
    .text-highlight {
        color: gold;
        font-size: 75%;
        margin-bottom: 10px;
        margin-top: 25px;
    }
    .text-highlight a {
        color: gold;
    }
    .monitoring {
        font-size: 75%;
        line-height: 1.25em;
        color: #a8a8a8;
        margin-bottom: 25px;
    }
    .man {
        font-size: 75%;
        text-align: left;
    }
    .man .comment {
        color: #737373;
        font-style: italic;
    }
    .man i {
        color: #e6e673;
    }
    select {
        font-size: 20px;
        width: 45px;
        margin-right: 5px;
    }
    div.select {
        position: relative;
        display: inline-block;
        height: 15em;
    }
    div.select label {
        position: absolute;
        top: 28px;
        left: 25px;
        transform: rotate(45deg);
        transform-origin: left top 0;
    }
    table {
        margin-left: auto;
        margin-right: auto;
        border-collapse: collapse;
        border-top: 1px solid #333333;
        border-bottom: 1px solid #333333;
        width: 100%;
        max-width: 400px;
    }
    table th,
    table td {
        border-top: 1px solid #333333;
        border-bottom: 1px solid #333333;
    }
    table th {
        width: 13em;
        text-align: right;
        padding: 0.2em 1em 0.2em 0;
    }
    table td {
        text-align: left;
        padding: 0.2em 0 0.2em 1em;
    }
    .blurb {
        font-size: 75%;
        color: #fff !important;
    }
    .blurb a {
        color: #fff;
    }
    #content {
        min-height: 500px;
    }
    div.warning {
        color: saddlebrown;
        font-size: 75%;
        height: 0;
    }
    .text-editor input {
        font-family: "Courier New", Courier, monospace;
        text-align: center;
        font-size: 250%;
        width: 100%;
        background-color: #333333;
        border: 1px solid #cccccc;
        border-radius: 0.6em;
        color: #ffffff;
        padding-top: 0.075rem;
    }
    .text-editor input.invalid {
        border: 1px solid darkred;
    }
    .text-editor input.warning {
        border: 1px solid saddlebrown;
    }
    .text-editor input:focus {
        outline: none;
    }
    .text-editor input::-ms-clear {
        width: 0;
        height: 0;
    }
    .text-editor input::-moz-selection {
        color: #ffff80;
        background-color: rgba(255, 255, 128, 0.2);
    }
    .text-editor input::selection {
        color: #ffff80;
        background-color: rgba(255, 255, 128, 0.2);
    }
    .clickable {
        text-decoration: underline;
        cursor: pointer;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
    }
    .part-explanation {
        font-size: 75%;
        color: #a8a8a8;
        height: 24em;
    }
    .part-explanation div {
        display: inline-block;
        vertical-align: top;
        margin: 0 1em 0 0;
    }
    .part-explanation .active {
        color: #ffff80;
    }
    .part-explanation .invalid {
        background-color: darkred;
    }
    .part-explanation .warning {
        background-color: saddlebrown;
    }
    .part-explanation .clickable {
        border-radius: 1em;
        padding: 0.1em 0.36em;
    }
    .part-explanation .clickable:last-child {
        margin: 0;
    }
    .human-readable {
        font-size: 200%;
        font-family: Georgia, serif;
        min-height: 2.2em;
        display: -ms-flexbox;
        display: flex;
        -ms-flex-pack: end;
        justify-content: flex-end;
        -ms-flex-line-pack: end;
        align-content: flex-end;
        -ms-flex-direction: column;
        flex-direction: column;
        margin-bottom: 0.2em;
        margin-top: 1.25em;
    }
    .human-readable .active {
        color: #ffff80;
    }
    .next-date {
        font-size: 75%;
        margin-left: 0.5em;
    }
    .tips {
        font-size: 75%;
        text-align: left;
        display: inline-block;
        vertical-align: top;
        margin-bottom: 3em;
    }
    .tips .title {
        font-weight: bold;
    }
    .example {
        text-align: right;
        font-size: 75%;
        margin-top: -1em;
        margin-bottom: 7px;
    }
    #footer {
        font-size: 75%;
        margin-top: 40px;
    }
    #footer span {
        margin: 0 1em;
    }
    .monitor {
        border: 1px dotted #666666;
        border-radius: 0.2em;
        margin: 3em 0;
        padding: 0.2em 0;
        min-height: 10em;
        color: #666666;
    }
    .monitor a,
    .monitor a:visited,
    .monitor a:active {
        color: #666666;
    }
    .monitor .input-copy {
        display: -ms-flexbox;
        display: flex;
        margin: 0.5em 0;
    }
    .monitor .input-copy input {
        -ms-flex: 1 1 auto;
        flex: 1 1 auto;
        margin: 0 0;
        border: none;
        color: inherit;
        font-family: inherit;
        font-size: inherit;
        padding: 0.2em 0.5em;
        background-color: #262626;
    }
    .monitor .input-copy button {
        -ms-flex: 0 1 auto;
        flex: 0 1 auto;
        line-height: 0;
        margin: 0;
        font-family: inherit;
        font-size: inherit;
        background-color: #333333;
        border-color: #666666;
        border-width: 1px;
    }
    .monitor .input-copy .copy {
        fill: #666666;
        color: inherit;
    }
    .monitor .info {
        font-size: 75%;
        margin-top: 2em;
    }
    @media screen and (max-width: 400px) {
        .text-editor input {
            font-size: 200%;
        }
        .example {
            display: none;
        }
        .part-explanation .clickable {
            padding: 0.1em 0.01em;
            margin: 0 0.2em 0 0;
        }
        table {
            max-width: 360px;
        }
        table th {
            width: 7em;
        }
    }
</style>
