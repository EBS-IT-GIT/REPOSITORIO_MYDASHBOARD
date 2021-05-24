<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Contracts\Queue\ShouldQueue;
use App\Http\Controllers;


class emailLaravel extends Mailable
{
    use Queueable, SerializesModels;
    private $user;
    /**
     * Create a new message instance.
     *
     * @return void
     */
    public function __construct($user)
    {
        $this->user = $user;
      
    }

    /**
     * Build the message.
     *
     * @return $this
     */
    public function build()
    {   
       
        $this->subject('Aviso SLA '.$this->user->name);
        $this->cc($this->user->cc);
        $this->to($this->user->email);
        $this->bcc($this->user->bcc);
        return $this->view('emails',[
            'user'=>$this->user,
        ]);
    }
}
