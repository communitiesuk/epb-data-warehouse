require "json"

# tr=<<DOC
#
# The assessment 2775-3531-4452-8806-7325
# (no value)
# production
# (no value)
# Feb 6, 2026 4:04:02 PM UTC
# dc1dd5d1
# E The assessment 0215-3248-7445-8460-6710
# (no value)
# production
# (no value)
# Feb 6, 2026 4:00:17 PM UTC
# 4863a482
# The assessment 5430-7635-8442-1621-8706
# (no value)
# production
# (no value)
# Feb 6, 2026 4:00:17 PM UTC
# 9f763f71
# The assessment 0643-7266-2002-0329-0602
# (no value)
# production
# (no value)
# Feb 6, 2026 3:28:54 PM UTC
# 74a70431
# The assessment 0643-7266-2002-0329-0602
# (no value)
# production
# (no value)
# Feb 6, 2026 3:28:53 PM UTC
# 50a905dd
# The assessment 0643-7266-2002-0329-0602
# (no value)
# production
# (no value)
# Feb 6, 2026 3:28:53 PM UTC
# c59a6e49
# The assessment 2308-7558-7521-5620-2863
# (no value)
# production
# (no value)
# Feb 6, 2026 3:28:49 PM UTC
# 1b0f3928
# The assessment 9541-2963-1718-3016-5846
# (no value)
# production
# (no value)
# Feb 6, 2026 3:22:53 PM UTC
# 50d6bed9
# The assessment 2085-1269-1966-1206-2725
# (no value)
# production
# (no value)
# Feb 6, 2026 3:19:39 PM UTC
# 50b3a085
# The assessment 0300-2505-6520-2806-5801
# (no value)
# production
# (no value)
# Feb 6, 2026 3:18:43 PM UTC
# d690a79b
# The assessment 0369-3058-1202-1136-8204
# (no value)
# production
# (no value)
# Feb 6, 2026 3:18:19 PM UTC
# fbffff3b
# The assessment 9736-8822-0500-0376-8206
# (no value)
# production
# (no value)
# Feb 6, 2026 3:14:28 PM UTC
# 36f3782e
# The assessment 0217-9838-2281-0421-4234
# (no value)
# production
# (no value)
# Feb 6, 2026 3:11:57 PM UTC
# 3eb094c0
# The assessment 0023-0203-4706-1606-8500
# (no value)
# production
# (no value)
# Feb 6, 2026 3:07:04 PM UTC
# f2794a16
# The assessment 2294-1812-1954-0598-7101
# (no value)
# production
# (no value)
# Feb 6, 2026 3:07:02 PM UTC
# 0e0a3172
# The assessment 5970-4700-0251-7825-5858
# (no value)
# production
# (no value)
# Feb 6, 2026 3:06:48 PM UTC
# d51aba41
# The assessment 5970-4700-0251-7825-5858
# (no value)
# production
# (no value)
# Feb 6, 2026 3:06:48 PM UTC
# 42f9105c
# The assessment 0022-1209-3206-7602-1804
# (no value)
# production
# (no value)
# Feb 6, 2026 3:06:25 PM UTC
# 27391833
# The assessment 2480-6622-0060-0101-2005
# (no value)
# production
# (no value)
# Feb 6, 2026 3:02:56 PM UTC
# 84a7a7e2
# The assessment 4985-2995-8601-5980-5565
# (no value)
# production
# (no value)
# Feb 6, 2026 3:01:44 PM UTC
# 32abfb1f
# The assessment 4636-0822-9500-0275-8206
# (no value)
# production
# (no value)
# Feb 6, 2026 2:59:51 PM UTC
# 73385634
# The assessment 4800-8840-0322-2502-3263
# (no value)
# production
# (no value)
# Feb 6, 2026 2:56:05 PM UTC
# dada9ff8
# The assessment 0736-4329-7500-0936-8226
# (no value)
# production
# (no value)
# Feb 6, 2026 2:53:09 PM UTC
# 0116b66e
# The assessment 2860-8645-9232-8947-0238
# (no value)
# production
# (no value)
# Feb 6, 2026 2:52:41 PM UTC
# 81adee89
# The assessment 0291-0209-2706-3307-3810
# (no value)
# production
# (no value)
# Feb 6, 2026 2:51:18 PM UTC
# 0675f510
# The assessment 0026-0201-2906-6744-3714
# (no value)
# production
# (no value)
# Feb 6, 2026 2:50:19 PM UTC
# 6b2af378
# The assessment 2254-3921-5759-6708-4421
# (no value)
# production
# (no value)
# Feb 6, 2026 2:47:55 PM UTC
# 1472eaec
# The assessment 9428-5745-5792-4221-4602
# (no value)
# production
# (no value)
# Feb 6, 2026 2:47:55 PM UTC
# 7b44448f
# The assessment 0562-3058-6202-9826-8204
# (no value)
# production
# (no value)
# Feb 6, 2026 2:47:46 PM UTC
# d1b83128
# The assessment 2760-1299-1558-8200-3301
# (no value)
# production
# (no value)
# Feb 6, 2026 2:43:49 PM UTC
# a0312385
# The assessment 6636-6822-8500-0266-8206
# (no value)
# production
# (no value)
# Feb 6, 2026 2:43:36 PM UTC
# c97bb3e2
# The assessment 6487-8039-3265-2402-2203
# (no value)
# production
# (no value)
# Feb 6, 2026 2:43:27 PM UTC
# e2374476
# The assessment 0390-3326-6520-2806-4885
# (no value)
# production
# (no value)
# Feb 6, 2026 2:42:57 PM UTC
# 2b53e2b4
# The assessment 0350-6684-6020-2406-4261
# (no value)
# production
# (no value)
# Feb 6, 2026 2:42:27 PM UTC
# 3e979c11
# The assessment 0350-6684-6020-2406-4261
# (no value)
# production
# (no value)
# Feb 6, 2026 2:42:27 PM UTC
# 01c46ec1
# The assessment 0340-2416-4510-2795-3485
# (no value)
# production
# (no value)
# Feb 6, 2026 2:40:19 PM UTC
# b4ddf4e1
# The assessment 0370-2126-9520-2806-1821
# (no value)
# production
# (no value)
# Feb 6, 2026 2:39:19 PM UTC
# 1c4bfde3
# The assessment 0817-7922-9689-0875-9280
# (no value)
# production
# (no value)
# Feb 6, 2026 2:36:53 PM UTC
# 67fe3e7b
# The assessment 0817-7922-9689-0875-9280
# (no value)
# production
# (no value)
# Feb 6, 2026 2:36:53 PM UTC
# e9ec05c2
# The assessment 9727-0723-3236-2803-7633
# (no value)
# production
# (no value)
# Feb 6, 2026 2:35:06 PM UTC
# ea6165d3
# The assessment 0350-2685-9520-2706-2881
# (no value)
# production
# (no value)
# Feb 6, 2026 2:34:02 PM UTC
# 87f7fc5f
# The assessment 6125-4727-6833-9713-9799
# (no value)
# production
# (no value)
# Feb 6, 2026 2:29:28 PM UTC
# 2c9f8c3f
# The assessment 6102-9885-8547-2842-6771
# (no value)
# production
# (no value)
# Feb 6, 2026 2:29:14 PM UTC
# a8541c77
# The assessment 7638-1016-6012-2702-1206
# (no value)
# production
# (no value)
# Feb 6, 2026 2:28:19 PM UTC
# a9f8b208
# The assessment 0999-9682-8533-3830-5479
# (no value)
# production
# (no value)
# Feb 6, 2026 2:27:59 PM UTC
# 21b43480
# The assessment 0999-9682-8533-3830-5479
# (no value)
# production
# (no value)
# Feb 6, 2026 2:27:59 PM UTC
# 985e5c66
# The assessment 7649-6036-0022-2002-0806
# (no value)
# production
# (no value)
# Feb 6, 2026 2:27:08 PM UTC
# e3cd67b1
# The assessment 8636-2822-8500-0216-8206
# (no value)
# production
# (no value)
# Feb 6, 2026 2:27:01 PM UTC
# d7a8283e
# The assessment 8636-2822-8500-0216-8206
# (no value)
# production
# (no value)
# Feb 6, 2026 2:27:01 PM UTC
# 239ff8ec
# The assessment 3138-1516-1942-5809-1206
# (no value)
# production
# (no value)
# Feb 6, 2026 2:26:01 PM UTC
# DOC
#
# rrns = str.split(/\n+/).select{|i| i=~/The assessment / }.map{ |v| v.match(/[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}/)[0] }
# pp rrns
# pp rrns.count

body = <<~DOC
  {
    "keys": [
      {
        "kty": "EC",
        "use": "sig",
        "crv": "P-256",
        "kid": "644af598b780f54106ca0f3c017341bc230c4f8373f35f32e18e3e40cc7acff6",
        "x": "5URVCgH4HQgkg37kiipfOGjyVft0R5CdjFJahRoJjEw",
        "y": "QzrvsnDy3oY1yuz55voaAq9B1M5tfhgW3FBjh_n_F0U",
        "alg": "ES256",
      },
      {
        "kty": "EC",
        "use": "sig",
        "crv": "P-256",
        "kid": "355a5c3d-7a21-4e1e-8ab9-aa14c33d83fb",
        "x": "BJnIZvnzJ9D_YRu5YL8a3CXjBaa5AxlX1xSeWDLAn9k",
        "y": "x4FU3lRtkeDukSWVJmDuw2nHVFVIZ8_69n4bJ6ik4bQ",
        "alg": "ES256",
      },
      {
        "kty": "RSA",
        "e": "AQAB",
        "use": "sig",
        "kid": "76e79bfc350137593e5bd992b202e248fc97e7a20988a5d4fbe9a0273e54844e",
        "alg": "RS256",
        "n": "lGac-hw2cW5_amtNiDI-Nq2dEXt1x0nwOEIEFd8NwtYz7ha1GzNwO2LyFEoOvqIAcG0NFCAxgjkKD5QwcsThGijvMOLG3dPRMjhyB2S4bCmlkwLpW8vY4sJjc4bItdfuBtUxDA0SWqepr5h95RAsg9UP1LToJecJJR_duMzN-Nutu9qwbpIJph8tFjOFp_T37bVFk4vYkWfX-d4-TOImOOD75G0kgYoAJLS2SRovQAkbJwC1bdn_N8yw7RL9WIqZCwzqMqANdo3dEgSb04XD_CUzL0Y2zU3onewH9PhaMfb11JhsuijH3zRA0dwignDHp7pBw8uMxYSqhoeVO6V0jz8vYo27LyySR1ZLMg13bPNrtMnEC-LlRtZpxkcDLm7bkO-mPjYLrhGpDy7fSdr-6b2rsHzE_YerkZA_RgX_Qv-dZueX5tq2VRZu66QJAgdprZrUx34QBitSAvHL4zcI_Qn2aNl93DR-bT8lrkwB6UBz7EghmQivrwK84BjPircDWdivT4GcEzRdP0ed6PmpAmerHaalyWpLUNoIgVXLa_Px07SweNzyb13QFbiEaJ8p1UFT05KzIRxO8p18g7gWpH8-6jfkZtTOtJJKseNRSyKHgUK5eO9kgvy9sRXmmflV6pl4AMOEwMf4gZpbKtnLh4NETdGg5oSXEuTiF2MjmXE",
      },
    ],
  }
DOC

pp body.class
