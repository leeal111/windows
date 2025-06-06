function ConvertTo12HourFormat {
    param (
        [string]$time24Hour
    )

    # Parse the input time
    $time = [datetime]::ParseExact($time24Hour, 'HH:mm', $null)

    # Convert to 12-hour format with AM/PM using invariant culture
    $time12Hour = $time.ToString('hh:mmtt', [System.Globalization.CultureInfo]::InvariantCulture)

    return $time12Hour
}
