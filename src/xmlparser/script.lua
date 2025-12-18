local xml = require("xmlparser")

local parsed = xml:parse([[

<?xml version = "1" ?>
<root thing = "wow">
    <hello>
    </hello>
    <hello>
        aaaa
    </hello>
</root>

]])
logTable(parsed, 10)