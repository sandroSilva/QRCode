/**************************************************************************
* LOGOSWARE Class Library.
*
* Copyright 2009 (c) LOGOSWARE (http://www.logosware.com) All rights reserved.
*
*
* This program is free software; you can redistribute it and/or modify it under
* the terms of the GNU General Public License as published by the Free Software
* Foundation; either version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this program; if not, write to the Free Software Foundation, Inc., 59 Temple
* Place, Suite 330, Boston, MA 02111-1307 USA
*
**************************************************************************/ 
package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.Timer;
	
	import com.logosware.event.QRdecoderEvent;
	import com.logosware.event.QRreaderEvent;
	import com.logosware.utils.QRcode.QRdecode;
	import com.logosware.utils.QRcode.GetQRimage;
	
	/**
	 * QRコード解析クラスの使用例です
	 * @author Kenichi UENO
	 * alterado por @sandrilho
	 */
	public class LeitorQrCode extends Sprite 
	{
		//declaração das variáveis
		private var getQRimage:GetQRimage;
		private var qrDecode:QRdecode = new QRdecode();
		
		private var cameraView:Sprite;
		private var camera:Camera;
		private var video:Video = new Video(320,240);
		
		private var cameraTimer:Timer = new Timer(2000);
		private var resultadoArray:Array = ["", "", ""];

		public function LeitorQrCode():void 
			{
				cameraTimer.addEventListener(TimerEvent.TIMER, getCamera);
				cameraTimer.start();
				getCamera();
			}

		//verificando se a webcam está conectada e ligada
		private function getCamera(e:TimerEvent = null):void
			{
				camera = Camera.getCamera();
				 if (Camera.isSupported)
					{
						
						if (!camera)
							{
								errorCamera();
							} 
						/*else if (camera.muted) 
							{
								muteCamera();
							}*/
						else 
							{
								cameraTimer.stop();
								onStart();					
							}				
					}
				else
					{
						errorCameraNotSuppport();
					}
			}
			
		//inicio da webcam
		private function onStart():void 
			{
				cameraView = criaCameraView();
				this.addChild(cameraView);
				getQRimage = new GetQRimage(video);
				getQRimage.addEventListener(QRreaderEvent.QR_IMAGE_READ_COMPLETE, onQrImageReadComplete);
				qrDecode.addEventListener(QRdecoderEvent.QR_DECODE_COMPLETE, onQrDecodeComplete);
				this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
			
		/**
		 * Retorno webcam não esteja instalada (não se aplica se ela não estiver conectada)
		 */
		private function errorCamera():void 
			{
				trace("camera não detectada!");
			}
			
		/**
		 * Retorno caso não encontre a áudio || as permissões de acesso podem ser diferentes
		 */
		private function muteCamera():void 
			{
				trace("você não tem áudio!");
			}
			
		/**
		 * Camera não suportada
		 */
		private function errorCameraNotSuppport():void 
			{
				trace("você não tem áudio!");
			}	
			
		/**
		 * Function para criar, configurar e jogar no palco a imagem da webcam
		 */
		private function criaCameraView():Sprite 
			{
				//configura imagem da webcam
				camera.setQuality(0, 100);
				camera.setMode(320,240,30,false);
				video.attachCamera(camera);
				
				//configura fundo imagem da webcam
				var sprite:Sprite = new Sprite();
				sprite.graphics.beginFill(0x000000);
				sprite.graphics.drawRect(0, 0, 320+30, 240+30);
				
				//centraliza imagem da webcam
				var videoHolder:Sprite = new Sprite();
				videoHolder.addChild( video );
				videoHolder.x = videoHolder.y = 15;
	
				sprite.addChild(videoHolder);
				return sprite;
			}
			
		/**
		 * Function para processar o QR Code.
		 */
		private function onEnterFrame(e:Event):void
			{
				if( camera.currentFPS > 0 )
					{
						getQRimage.process();
					}
			}
			
		/**
		 * Function que vai enviar o QR Code para a classe de decodificação.
		 */
		private function onQrImageReadComplete(e:QRreaderEvent):void
			{
				qrDecode.setQR(e.data);  
				qrDecode.startDecode();  
			}
			
		/**
		 *  Function que retorna o resultado da decodificado do QR Code.
		 */
		private function onQrDecodeComplete(e:QRdecoderEvent):void 
			{
				resultadoArray.shift();
				resultadoArray.push(e.data);  
				if (resultadoArray[0] == resultadoArray[1] && resultadoArray[1] == resultadoArray[2]) 
					{
						trace(e.data);
						onClose();
					}
			}
			
		/**
		 * Function para zerar os arrays criados.
		 */
		private function onClose():void 
			{
				resultadoArray = ["", "", ""];
				cameraView.filters = [];
			}
	}
}