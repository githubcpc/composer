(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -ev

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# Pull the latest Docker images from Docker Hub.
docker-compose pull
docker pull hyperledger/fabric-ccenv:x86_64-1.0.0-alpha

# Kill and remove any running Docker containers.
docker-compose -p composer kill
docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
docker ps -aq | xargs docker rm -f

# Start all Docker containers.
docker-compose -p composer up -d

# Wait for the Docker containers to start and initialize.
sleep 10

# Create the channel on peer0.
docker exec peer0 peer channel create -o orderer0:7050 -c mychannel -f /etc/hyperledger/configtx/mychannel.tx

# Join peer0 to the channel.
docker exec peer0 peer channel join -b mychannel.block

# Fetch the channel block on peer1.
docker exec peer1 peer channel fetch -o orderer0:7050 -c mychannel

# Join peer1 to the channel.
docker exec peer1 peer channel join -b mychannel.block

# Open the playground in a web browser.
case "$(uname)" in 
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else   
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �%Y �]Ys�:�g�
j^��xߺ��F���6�`��R��ml����t�N'�߾���:IȲ�t�sđp�C����hLC�˧ �A�dqEiyx��GQ�IG� (����9�y�m���Z��&�w���r���C�>���I7	���ho��*��q��)��*���������@�X�B�X%�2�f�/ީ.�?J�ٕ�K���{�˯�[G���'�j���_���?��(�_�˟�i�������t�Uؙ��t�B�A����5W�أ���(I��_���w�O�h�r���C�1�Fhsp�<��)�r	��0JS�C6�,BQ>B:>���`��x�(��M�Yc���Q��O�"^��8�>��x�9�K)��p�U��Zy�j=]6�!�ڢuʃ���Me��餾0	���
֣ׂ���IkA�*̄Ԫ�O�$Q��׍�B���f4�-�x�X��M�	ܑ�㹉]��hn�:Г�OXz8��$�n���i&������ő��"�-TiK��B]��:5VT��������4�mo9]�~���cx��GaT��W
>J�wW����_>��+�-{����)x��yQ7dI�s�y��e�o<�n2���)+��g}o�9�5W�E����p=�Ϻ=M��-� ^�S�b�2G�P�t ���0)��㝻$c��
��򸽢0i+��də=Rg�Q���?<Qd�a.�9{Žh��&�or���s��^�$"�J�ף�(f49O���>-�������7Me/��k~�N��b�୭=���y�!�yޔk�Kika���1���8=n�.fBv�A�&�xh��Rn�pJ�;�i��B�ӛ�B"N�UqI(m����|?�Ȅ�1Ӱ��X�1j��>����f+�d�r�n���,7GQ�;S��kQ�ё�@��	����&"�g�w�f?�y4�P/^�[ix⹰� �����H��eQV���I8h�71��o�L��V�Q��@���Vc$J�Ms�<0rQ� 	�"xY�����\��$�H�+qc6K��9����oY���[M���F��QW2i1��H�E#�3�^4MG�.����lx6���Y~I�������G��K���Q�S�U�G��?��.a��%�5�g9�;�;�ׁzd�5�{���Ǜ�D=q��%���|�!q���^B�Џ��
|Hʐ�zGE󫂩�d�i9���2s��I��G�:��2��4]� �l��b�p����Y.&�ne8�5�5�!���Y������|��,�{�̢��A�晘Y��N�]�����{�Х��Soz�.��Ti�LOT�Z�@n��ð�@
Zoi�rf�m qY�����+ d��TɌ�L�@����C� ���o䠛��>�u�^��[��kSR�F�D�����d:��u\6�.��̶��	�4���Q/%�E�l����ņ�熂�`~�n3�'0 ���臙\���p=E�̺9�8�7!����S���w�7�����!�*��|����y���������T���W���k���sL���O�o+�/�$�ό���RP��T�?�>�I���D1�(�ͯN�S$��w���@X$�q��\֡0�\�P��Y������e����G�?AW�_� ��o���a�Ѥ���#��u�v<K�s�G G��[e~8�����ص�`FL�9n��c���j)�z�"��֗s�3ܠ��Ȃ`�͍9�Z�k���M�`5��`�]��4��ދ_����S������������/��_��W��U������S�)� �?J������+o�����o�P�R�>BaJo�q���?������|�h�0�ެA����`p�{�i2����T�>2�2<�ēzo*ͭ��3A>�����$��&	s3����z�-��dް��1X~��@��t��ʝ��V�g���5��m�`\�EDRA�d���� N4�,�2�s���$g�@[���`�N��9����g�]��I��(/�A���{�?-L{�dЄ�NS,}�c�k~>4���ZLB6�m:-�m�Zgeϔ��uG=��f�T�%��K)ɜ�H^�n�@B�<�+��z�Z��|����?3�����|��?>���+�/��_�������o�����#�.�A+�/������U�)��������\����P�-��y
R����K��cl��s�u(�p�v};@�Y�sG�%Pa�a� !}�Y���*���C�<��I������*vE~�^������֘.�m���H�n���ñ'/H���?�@�N�E�:�$�А��r7��U6^�0�m�.3��)mw7p{G��=1�K�4x6����MF��sJɨ�~V������x~��G�_���4Q����7��{�;O���U��].����˔����	�������x��e�p��i'*������K�A/�?�bH�����?X!���?d��������������,F,�8�M��M��b��b������,����,��h�PTʐ���?8R��T��|>.X��"�?>�%�a��bL��vK����W���i�~�yq�g=�	^�뺻�V��KP=�#r�ec&�:�L��R>j��[>#~"�m��G��ZOE\TG��A�ك��W�?��G��������#���+������S��B���+�4�d_-T�L�!�W�?� ��V��C)x-��]�y���;Gb-GA���5��`�����������п?�c�y�T�ebxT�ٹK}�.�tw��ρnX�΁���~�9�Ѓ��6��2q�p��^��}1��.���G��&1]���6�����k��$�/�H�g�����f�N��7o�(6SS��v�N\4Wߛ��
�;g���|�G�-ãe��q�#=�$l��v�$f\h��k ��ݚ�r.k�)ZV�y:E��ڔ�9��r��nw�cC��B�w{�c ����䮷��,����à�bM p"�r65�y{_W\�y����Fw��4N3�Y�<%���?m{�ȡ �<�Jd&��'eM��������Z���"m�JC�y�`��_����+����?�W��߄ϙ�?ȭ܀�e��U����O�	���������6���f��ps/���B������qo(�g���@y�@wA޺d�d����5`�5M|��?�O΃��ɱ�&�t��*�{��3i/�eZ�o�JOM���G|k�r�F��0�S錉S��u��(�F"��j�ո��y��!�~��܇.���� ��Y6h��@]��v#x6�қnҷ��`�6��\��^Jfr��{���,�C�7z}��{���46a�D��h�"��������_:�r���*����?�,����S>c�W����!������Y����j��Z�������7��w�s���aX�����r�_n�]�������T�_���.���?����S��[)���	��i�P��"Y�eh��(�	�	� �]�}�pȀ�� �}�r]�q�N���P��_��~t�IW�?����?@i��-��C˜�lv�C���s�`�J���-�E������,�t�V�֕�FwOѽxCq=qh{{�c�F��sh}�
��A~���N���r���	�2�Q_��,6��Y����"w�'��_�Q�_�������?�����(Z��W)��I�k������ (�����ӯP���Hq�զK;���&��O���1��d�^���=C�P�z�\#W�"�ا����4�VK�9WR�]�$��2Ã�fW���ƅX�U�?9}0��M����I|-��딖ܥ����I�ʭ����Z!�M�*O�.V+��¯�z�'�}_�8W4����'�ծ��i�����8��v坺`-�K�A]×�����Oq�߫�=]����^�µo�*�������yZ�.��au[좱��Q�����:��t�!�@t����\���X����"ͮ��kE%��|���dQ������\;�\Ͼ��.:J�'ߺ��o^--���,���`{��ӿ������ڋ��-J�2iN���Yܛ����b����N��+��o?�M�v�����U������glQ��O[ ����ߩ�Y�̧��ƛ&_kpo�0���N���ֹ�U���#��k���O4a��B"?Rg5�|j��G�>�;��|8"�۞�������n(�\���.��M �|Wođ�ѐ�;0����*��o�d�?N6�|����߶���+Ó(��;;���
>[R��É~�dO��m>�����ƺN�q�\.����P�\p3\�=^��{�P��[���ۺ�Mɵ���m����&�_���M�F����'%�A�~Q>(��1���v[�v���s8\ۛ�ӵ����������<�͛��g�Lg̓�M�n�͠��LCĮ�~�H&�X$�g������ i$���R���H<��ֶ�P=I]���}N'��u�&ZL�2:]Z�����ٴ�xxfS��s@��0��Î��;��$�=�n��Dsp�n�\�wBs�-3�����n z)��6`��j���G���n+����6j��U� �������s�J���h2��n�B2MѺ�|b��z��Wَ�~�x7�sF#-�&��q��(���4b	�Y����t6ZV{߬�s�<�J��Ґ1˨�
ߪh�t�j��E��Y���Ma��M��4�"G�ӥ�l8���hpꛃS�N��N'F~0��|D��urw�N�_T$v �r�UY���`.�u���=�5��jL��X�A5���,�n"I��,�T�>��V�?d�9N��-�3z:��Ƌ��oFB��������}�_ߕ��^�
�qjM1�0��]� �$��>ͧk�㜻��m��1�3�t=l��3����E]䢹@٢J)�<(��v�f6 u��j����g��d&/G��O�����g�uTɨ��*�7V�x�s.H��=����n���43m&?�t눅��8/��f��8��ˈ	���91��h����Z;��O�}�a�+!��U{I2ta-����B�V/dy��>G���L���W��j:��>��Q�qѹ�@�{��'��{��w������Qc��������������8x�Nl�Z{�ߏ��j絖J\x`���.��П`,��E�U�uc�^�G�׳��V]����*���#��C9=�����Cgoo�vǙ_���ح��wO<����ڥG��9�
<C��B7����9�5�@8�C'��� ��š����9p�q��9���'������H�A���>=�Ծ�����d}����Y�<0"�Ὠ�%�,ף��m��$^�0{����� ��a���6���e�z�����`#G$7C�6�%�n�3�,�Q��!�n�_��[��!��L��P;e��k`�4��Wɝ.��i2_�Q,S�׃�vN6s��x� �8�7s��[�&�<��tw@?�Q�R��p����O�Y:8�.�cJt��'d�>��5�B(���J���*
.2!�ʞZ=��QB�Qʋr˩jK�	I�����	m���2Ų��z)5��I��^
Qx�K�����O�LX�	k3aWa�BO���!a�}6<�����֦���蚝�R3��=`����nUCLpl-��)و�[�]�d ����D`����2���ׯl�L��ITh�[��@kpGBI1&�w8��H�0�ᐕd�&���)�i�A��#ky�<��{�gd��
��D6ar��[E<��*�uвBP��Z�����/�d����ka(FIs�N��{�]��n&�uz;/rA�f�]���w�w_Y�Ǥ,K6`�Q�-wf3��Y.�};�J�`8�N3����=-���b��"�~%�c�TKlR�B�]l��P��2���6u8e���kE����B�
(��}Lϴ�Ԝ����]�,QՃ�|�>��IB��1�U`�@N�0�ՉD�'o�"���2V�9�NTA��-$�R�H͏�L9�+T�n_,!���B��{�,�E��_�,�������D�X�g(ߪpy�$�~	J hb�N
����m0/�W�<��C�a\�孝\;1���l�����0�h�	��%,&kRl���(� �0)W:S�dNY���.U&�	{�>��m�j�O%U��� K���Z�`	!��&�tчn0�fCRw|D��5U�MHy��P��H6)��2H�=�b���,N�g�}6�g[�g�8�?͉�k
j�ͫ���ڕ������X�b�t�������g�ȡ��>�f:3�f����<[9TQw��l����iC7B׀��^WS�D�g�7?�d������8��J���ō;�M�(��浶Z3�jh��TQ����u��@�u�8�ɒl�8��fm2�!��^�?�r��V3�V眅ά]������pCР �Y�V1k�]�_k=����n�d��e&OqY>�s��i\Q����y�e����~�yh�Z�(���3rBg W����G��sd�+~�C�qyy{zk���n~�K��R��K��ݣ���t�$�z���
A"�o��[����±/<h�#!Җ:����A�\t0���<�)�U,�Ypp�h��.88�0=��jMD�'�z�3��ᦇ��3�6�F�HzUQ�+�(G�[Z���8!��{��
���-"G��R���m�N'5����
�{LU������R�S`�����!<��9>~�!i��{��p�X8��I�A�����Lt��U]�Vb��L-G2�X��H_���w�	E�@%�W�ޖ��2Ά=Hvq�l�������?Іh'���^L�Du��5����m0M����pVn`��Tӊ�t���5�m�q��q������nӝ�[���ӆ?4vL�SL|�S �gwt�.x�T���V�]�w�a�����o�?9G��y�����xXv$�I[u�LG�F)\I"��rI&ZǼ� �S ��78�;X̠�`)*�q��g�"��8jPdR+0
�LWkʲ���al���`6¨M%��)e'.�Ƞ4F�)�)�S[� w�
Sb>ZvQ� �e�K�F�=\����`��E�t)%!TLG�����p�`�n,�(t��0�v�&Djl�ɷ�����!QW��m#(����K;� �{Ų�vG��W�R��'y9X(#.8�$����aFD�ʖ\�o��Ú�ؒp8��&K�Z�^�E��nw��%R�wi�=,�8l��3�Cy?�و�JN���N�L�B_+��V�m\��a��f��&�ZB��v�vG5��k�я����M�RQyM�5��n ���y-��`}�).	���	A�8���n���+���sqT�J��8	�����܋�bv���o��j�pǧ��o������K/���?]k�]�{�^���c�X8Q���8���z���������r ���g����Ko��� �x���M|󦿾��W�? z�$��8x*�~p�ڕޯ��䊞n��h:Q�m@g߈��O~�/6~'����_/��׿�'��)�����4E�|�	�9K�|զv��N��i�l��M����߿��i; mS;mj�M��}6�g{?P;ͷ��|�� U�B����z��&�&�A�-"�N1����L��1��=��_��^��&��<ۭ�y��T�S��3���6���gp��X���`9_�MM�Y�i�sf�h�=gƞ`O�����a�e�3s���G�s9f�\8�0�!Bk��6�]��1�9��_ju��b��>��>��>޷�i��c  